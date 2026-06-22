import * as functions from "firebase-functions";
import axios from "axios";

// Google Maps API response
interface GoogleDirectionsLeg {
  distance: { text: string; value: number };
  duration: { text: string; value: number };
}

interface GoogleDirectionsRoute {
  legs: GoogleDirectionsLeg[];
  overview_polyline: { points: string };
}

interface GoogleDirectionsResponse {
  status: string;
  routes: GoogleDirectionsRoute[];
}

// Output format for directions model
interface DirectionsModel {
  distanceTextString: string;
  durationTextString: string;
  distanceValueDigits: number;
  durationValueDigits: number;
  encodedPoints: string;
}

// Output format for a single ride option
interface RideOption {
  mode: string;
  name: string;
  iconName: string;
  price: number;
  duration: string;
  capacity: number;
  variant: string;
}

export const rideOptionsAndAddressModel = functions.https.onCall(
  async (data, context) => {
    const { origin, destination } = data;

    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated to call this function."
      );
    }

    console.log("Received data:", data);

    const apiKey = functions.config().maps.key;
    if (
      !origin ||
      !destination ||
      typeof origin.lat !== "number" ||
      typeof origin.lng !== "number" ||
      typeof destination.lat !== "number" ||
      typeof destination.lng !== "number"
    ) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Origin or destination coordinates are missing or invalid."
      );
    }

    let directionsRes;
    try {
      directionsRes = await axios.get<GoogleDirectionsResponse>(
        `https://maps.googleapis.com/maps/api/directions/json?destination=${destination.lat},${destination.lng}&origin=${origin.lat},${origin.lng}&mode=driving&key=${apiKey}`
      );
    } catch (err) {
      throw new functions.https.HttpsError(
        "unavailable",
        "Network error while calling Google Maps Directions"
      );
    }

    const responseData = directionsRes.data;

    if (responseData.status !== "OK") {
      switch (responseData.status) {
        case "NOT_FOUND":
          throw new functions.https.HttpsError(
            "not-found",
            "Invalid pickup or drop-off location."
          );
        case "ZERO_RESULTS":
          throw new functions.https.HttpsError(
            "not-found",
            "No route found."
          );
        case "OVER_QUERY_LIMIT":
          throw new functions.https.HttpsError(
            "resource-exhausted",
            "Too many requests."
          );
        case "REQUEST_DENIED":
          throw new functions.https.HttpsError(
            "permission-denied",
            "Request denied by Google Maps."
          );
        default:
          throw new functions.https.HttpsError(
            "internal",
            "Unknown error from Google Maps API."
          );
      }
    }

    const leg = responseData.routes[0].legs[0];
    const distanceMeters = leg.distance.value;
    const durationSeconds = leg.duration.value;

    if (distanceMeters > 77000) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Trip exceeds 77 km limit."
      );
    }

    const encodedPoints = responseData.routes[0].overview_polyline.points;

    const baseFare = 50;
    const perKm = distanceMeters / 1000;
    const perMin = durationSeconds / 60;

    const rideOptions: RideOption[] = [
      {
        mode: "Auto",
        name: "Zion Auto",
        iconName: "airport_shuttle",
        price: Math.round((baseFare + perKm * 6 + perMin * 1.2) * 100) / 100,
        duration: `${Math.round(perMin)} mins`,
        capacity: 3,
        variant: "Luxury",
      },
      {
        mode: "Car",
        name: "Zion Car",
        iconName: "directions_car",
        price: Math.round((baseFare + perKm * 10 + perMin * 2) * 100) / 100,
        duration: `${Math.round(perMin)} mins`,
        capacity: 4,
        variant: "Sedan",
      },
    ];

    const directions: DirectionsModel = {
      distanceTextString: leg.distance.text,
      durationTextString: leg.duration.text,
      distanceValueDigits: distanceMeters,
      durationValueDigits: durationSeconds,
      encodedPoints: encodedPoints,
    };

    return {
      directions,
      rideOptions,
    };
  }
);