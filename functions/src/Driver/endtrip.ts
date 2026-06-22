import * as functions from "firebase-functions";
import { admin } from "../config/firebaseAdmin";
import axios from "axios";

const db = admin.firestore();

interface GoogleDirectionsLeg {
  distance: { text: string; value: number };
  duration: { text: string; value: number };
}

const ONLINE_DRIVER_REFS: Record<string, string> = {
  Bike: "online_bike_driver",
  Car: "online_car_driver",
  Auto: "online_auto_driver",
};

interface GoogleDirectionsRoute {
  legs: GoogleDirectionsLeg[];
  overview_polyline: { points: string };
}

interface GoogleDirectionsResponse {
  status: string;
  routes: GoogleDirectionsRoute[];
}

type VehicleType = 'Bike' | 'Car' | 'Auto';

export const endTrip = functions.https.onCall(async (data, context) => {
  console.log("🚀 Raw input received:", JSON.stringify(data, null, 2));

    const { tripId, vehicleType, pickup, dropoff, forceEndTrip } = data as {
    tripId: string;
    vehicleType: VehicleType;
    pickup: { lat: number; lng: number };
    dropoff: { lat: number; lng: number };
    forceEndTrip: boolean;
    };

  if (
    !tripId ||
    !vehicleType ||
    !pickup || typeof pickup.lat !== "number" || typeof pickup.lng !== "number" ||
    !dropoff || typeof dropoff.lat !== "number" || typeof dropoff.lng !== "number"
  ) {
    throw new functions.https.HttpsError("invalid-argument", "Missing or invalid fields");
  }

  try {
    const apiKey = functions.config().maps.key;
    const directionsURL = `https://maps.googleapis.com/maps/api/directions/json?origin=${pickup.lat},${pickup.lng}&destination=${dropoff.lat},${dropoff.lng}&mode=driving&key=${apiKey}`;
    
    const directionsRes = await axios.get<GoogleDirectionsResponse>(directionsURL);
    const directionsData = directionsRes.data;

    if (directionsData.status !== "OK" || !directionsData.routes.length) {
      throw new functions.https.HttpsError("internal", "Failed to fetch directions from Google");
    }

    const leg = directionsData.routes[0].legs[0];
    const distanceMeters = leg.distance.value;
    const durationSeconds = leg.duration.value;

    // ✅ Check distance-to-dropoff condition (500m limit unless forced)
    if (!forceEndTrip && distanceMeters > 500) {
      return {
        status: "overlimit",
      };
    }

    // 💰 Fare calculation
    const fareMap = {
      Bike: calculate(distanceMeters, durationSeconds, 0.4, 0.3),
      Car: calculate(distanceMeters, durationSeconds, 0.4, 0.7),
      Auto: calculate(distanceMeters, durationSeconds, 0.5, 0.4),
    };

    const fareAmount = fareMap[vehicleType];
    if (!fareAmount) {
      throw new functions.https.HttpsError("invalid-argument", "Invalid vehicle type");
    }

    // 🔄 Firestore updates
    const tripRef = db.collection("trip_req").doc(tripId);
    const tripSnap = await tripRef.get();
    const tripData = tripSnap.data();
    const userId = tripData?.UserId;

    if (!userId) {
      throw new functions.https.HttpsError("not-found", "User ID not found for trip");
    }

    const userRef = db.collection("users").doc(userId);
    const driverId = context.auth?.uid;
    if (!driverId) {
      throw new functions.https.HttpsError("unauthenticated", "Driver not authenticated");
    }
    const driverRef = db.collection("drivers").doc(driverId);

    const timeInMinutes = Math.ceil(durationSeconds / 60);
    const distanceKm = distanceMeters / 1000;

    const batch = db.batch();

    batch.update(tripRef, {
      Distance: distanceKm,
      FareAmount: fareAmount.toFixed(2),
      Status: "ended",
      EndTime: admin.firestore.FieldValue.serverTimestamp(),
    });

    batch.update(userRef, {
      TripStatus: "NONE",
      GetRating: tripId,
      TotalKm: admin.firestore.FieldValue.increment(distanceKm),
      TotalMin: admin.firestore.FieldValue.increment(timeInMinutes),
    });

    batch.update(driverRef, {
      Status: "NONE",
      TripStatus: "NONE",
      TotalEarning: admin.firestore.FieldValue.increment(fareAmount),
      TotalRides: admin.firestore.FieldValue.increment(1),
      earningsToday: admin.firestore.FieldValue.increment(fareAmount),
      ridesToday: admin.firestore.FieldValue.increment(1),
      totalUpdatedTime: admin.firestore.Timestamp.now(),
      isOnline: true,
    });
    const onlinePath = ONLINE_DRIVER_REFS[vehicleType];
    
    if (onlinePath) {
      const onlineDriverRef = db.collection(onlinePath).doc(driverId);
      batch.set(onlineDriverRef, {
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      });
      console.log(`✅ Driver pushed back to ${onlinePath}`);
    }

    await batch.commit();

    return {
      status: "success",
      fareAmount: fareAmount.toFixed(2),
      distanceKm: distanceKm.toFixed(2),
      durationMin: timeInMinutes,
    };
  } catch (error) {
    console.error("🔥 Error in endTrip:", error);
    throw new functions.https.HttpsError("internal", "Failed to complete trip");
  }
});

function calculate(
  distanceMeters: number,
  durationSeconds: number,
  distanceRate: number,
  durationRate: number
): number {
  const distanceKm = distanceMeters / 1000;
  const durationMin = durationSeconds / 60;
  const baseFare = 2;
  const total = baseFare + distanceKm * distanceRate + durationMin * durationRate;
  return parseFloat(total.toFixed(2));
}