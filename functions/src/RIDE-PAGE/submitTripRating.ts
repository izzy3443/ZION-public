import * as functions from "firebase-functions";
import { admin } from "../config/firebaseAdmin";

const db = admin.firestore();

export const submitTripRating = functions.https.onCall(async (data, context) => {
  const { tripId, driverId, userId, rating, feedback } = data as {
    tripId: string;
    driverId: string;
    userId: string;
    rating: number;
    feedback?: string;
  };

  if (!tripId || !driverId || !userId || typeof rating !== "number") {
    throw new functions.https.HttpsError("invalid-argument", "Missing or invalid fields.");
  }

  try {
    const tripRef = db.collection("trip_req").doc(tripId);
    const userRef = db.collection("users").doc(userId);
    const driverRef = db.collection("drivers").doc(driverId);

    // 1. Update trip document with rating and feedback
    await tripRef.update({
      UserRating: rating,
      UserFeedback: feedback || "",
    });

    // 2. Clear 'GetRating' field in user document
    await userRef.update({
    GetRating: null,
    });

    // 3. Update driver's average rating
    const driverSnap = await driverRef.get();
    if (!driverSnap.exists) {
      throw new functions.https.HttpsError("not-found", "Driver not found");
    }

    const driverData = driverSnap.data()!;
    const currentRating = (driverData.Rating || 5.0) as number;
    const totalRides = (driverData.TotalRides || 0) as number;

    const newAverage = ((currentRating * totalRides) + rating) / (totalRides + 1);

    await driverRef.update({
      Rating: parseFloat(newAverage.toFixed(1)),
    });

    return { success: true, newRating: newAverage.toFixed(1) };
  } catch (err) {
    console.error("❌ submitTripRating failed:", err);
    throw new functions.https.HttpsError("internal", "Failed to submit rating.");
  }
});