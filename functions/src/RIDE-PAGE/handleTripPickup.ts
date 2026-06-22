import * as functions from "firebase-functions";
import { admin } from "../config/firebaseAdmin";

const db = admin.firestore();

export const handleTripPickup = functions.https.onCall(
  async (data, context) => {
    const { tripId }: { tripId: string } = data;

    if (!tripId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing tripId"
      );
    }

    try {
      const tripRef = db.collection("trip_req").doc(tripId);
      const tripSnap = await tripRef.get();

      if (!tripSnap.exists) {
        throw new functions.https.HttpsError("not-found", "Trip not found");
      }

      await tripRef.update({
        Status: "picked_up",
        PickupTime: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { status: "success" };
    } catch (error: any) {
      console.error("❌ Error in handleTripPickup:", error);
      throw new functions.https.HttpsError(
        "internal",
        error.message || "Failed to update pickup"
      );
    }
  }
);