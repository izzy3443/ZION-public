import * as functions from "firebase-functions";
import { admin } from "../config/firebaseAdmin";

const db = admin.firestore();

export const cancelTrip = functions.https.onCall(async (data, context) => {
  const {
    tripId,
    userId,
    driverId,
    cancelledBy,
    cancelReason,
  } = data as {
    tripId: string;
    userId: string;
    driverId: string;
    cancelledBy: "user" | "driver";
    cancelReason: string;
  };

  console.log("📦 Cancel trip data received:", data);

  if (!tripId || !userId || !driverId || !cancelReason) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing required parameters"
    );
  }

  try {
    const tripRef = db.collection("trip_req").doc(tripId);
    const userRef = db.collection("users").doc(userId);
    const driverRef = db.collection("drivers").doc(driverId);

    const batch = db.batch();

    batch.update(tripRef, {
      Status: cancelledBy === "driver" ? "cancelledByDriver" : "cancelledByUser",
      CancelReason: cancelReason,
    });

    batch.update(userRef, {
      TripStatus: "NONE",
    });

    batch.update(driverRef, {
      TripStatus: "NONE",
      Status: "NONE",
    });

    await batch.commit();

    return { success: true };
  } catch (error: any) {
    console.error("🔥 Error in cancelTrip:", error);
    throw new functions.https.HttpsError(
      error.code || "internal",
      error.message || "Failed to cancel trip"
    );
  }
});
