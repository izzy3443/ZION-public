import * as functions from "firebase-functions";
import axios from "axios";


interface GoogleDirectionsResponse {
  status: string;
  routes: {
    legs: {
      distance: { text: string; value: number };
      duration: { text: string; value: number };
    }[];
    overview_polyline: { points: string };
  }[];
}

interface DirectionsModel {
  distanceTextString: string;
  durationTextString: string;
  distanceValueDigits: number;
  durationValueDigits: number;
  encodedPoints: string;
}


export const getDirectionDetailsFromApi = functions.https.onCall(
  async (data, context): Promise<DirectionsModel> => {

    /* ----------------------------- Auth check ----------------------------- */
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated."
      );
    }

    /* --------------------------- Validate input --------------------------- */
    const { source, destination } = data;

    if (
      !source ||
      !destination ||
      typeof source.lat !== "number" ||
      typeof source.lng !== "number" ||
      typeof destination.lat !== "number" ||
      typeof destination.lng !== "number"
    ) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Invalid pickup or drop-off location"
      );
    }

    /* ------------------------- Secure API key load ------------------------ */
    const apiKey = functions.config().maps.key;

    const url =
      `https://maps.googleapis.com/maps/api/directions/json` +
      `?origin=${source.lat},${source.lng}` +
      `&destination=${destination.lat},${destination.lng}` +
      `&mode=driving` +
      `&key=${apiKey}`;

    try {
      /* -------------------- TYPED AXIOS CALL (FIX HERE) -------------------- */
      const response =
        await axios.get<GoogleDirectionsResponse>(url);

      const responseFromApi = response.data;

      const status = responseFromApi.status;

      /* ----------------------- Same Dart error logic ----------------------- */
      if (status !== "OK") {
        switch (status) {
          case "NOT_FOUND":
            throw new functions.https.HttpsError(
              "not-found",
              "Invalid pickup or drop-off location"
            );

          case "ZERO_RESULTS":
            throw new functions.https.HttpsError(
              "not-found",
              "No route could be found between these locations."
            );

          case "OVER_QUERY_LIMIT":
            throw new functions.https.HttpsError(
              "resource-exhausted",
              "Too many requests. Try again later."
            );

          case "REQUEST_DENIED":
            throw new functions.https.HttpsError(
              "permission-denied",
              "Request denied"
            );

          default:
            throw new functions.https.HttpsError(
              "internal",
              "Unable to fetch directions"
            );
        }
      }

      /* ---------------------------- Parse leg ----------------------------- */
      const leg = responseFromApi.routes[0].legs[0];

      return {
        distanceTextString: leg.distance.text,
        durationTextString: leg.duration.text,
        distanceValueDigits: leg.distance.value,
        durationValueDigits: leg.duration.value,
        encodedPoints:
          responseFromApi.routes[0].overview_polyline.points,
      };

    } catch (error) {
      console.error("Directions error:", error);

      throw new functions.https.HttpsError(
        "unavailable",
        "Unable to fetch directions"
      );
    }
  }
);