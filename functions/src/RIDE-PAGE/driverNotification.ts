import * as functions from "firebase-functions";
import { admin } from "../config/firebaseAdmin";

const db = admin.firestore();
const messaging = admin.messaging();

export const notifyDriverAndWait = functions.https.onCall(async (data) => {
  const {
  driverId,
  tripId,
  passengerName,
  pickup,
  dropoff,
  fairAmount,
  duration, // ✅ added
  } = data;

  if (!driverId || !tripId || !pickup || !dropoff || !fairAmount || !duration) {
  throw new functions.https.HttpsError("invalid-argument", "Missing fields");
  }

  const driverRef = db.collection("drivers").doc(driverId);

  try {
    const driverSnapshot = await driverRef.get();
    const deviceToken = driverSnapshot.get("deviceToken");
    const driverStatus = driverSnapshot.get("TripStatus");

    if (!deviceToken) {
      throw new functions.https.HttpsError(
        "not-found",
        "Driver device token not found"
      );
    }

    if (driverStatus === "NONE" || driverStatus === "cancelled") {
      await driverRef.update({ TripStatus: tripId });

      // System notification (optional for foreground)
      // Foreground Notification
  await messaging.send({
  token: deviceToken,
  notification: {
    title: `NEW TRIP REQUEST ${passengerName ?? ""}`,
    body: `Pickup: ${pickup}\nDropoff: ${dropoff}\nFare: ₹${fairAmount}\nETA: ${duration}`, // ✅ include duration
  },
  data: {
    tripId,
    passengerName: passengerName ?? "",
    pickup,
    dropoff,
    fairAmount,
    duration, // ✅ include
  },  
  });

  
  await messaging.send({
  token: deviceToken,
  android: {
    priority: "high",
  },
  data: {
    tripId,
    passengerName: passengerName ?? "",
    pickup,
    dropoff,
    fairAmount,
    duration, // ✅ include
    showOverlay: "true",
  },  
  });

//   await messaging.send({
//   token: deviceToken,

//   android: {
//     priority: "high",
//   },

//   notification: {
//     title: `NEW TRIP REQUEST ${passengerName ?? ""}`,
//     body: `Pickup: ${pickup}
// Dropoff: ${dropoff}
// Fare: ₹${fairAmount}
// ETA: ${duration}`,
//   },

//   data: {
//     action: "NEW_TRIP",

//     tripId,
//     passengerName: passengerName ?? "",
//     pickup,
//     dropoff,
//     fairAmount,
//     duration,

//     showOverlay: "true",
//   },
// });

      console.log("Notification sent. Polling for 15 seconds...");

      const maxTries = 8;
      for (let i = 0; i < maxTries; i++) {
        console.log(`Polling attempt ${i + 1}...`);
        await new Promise((resolve) => setTimeout(resolve, 2000));
        const updatedSnapshot = await driverRef.get();
        const updatedStatus = updatedSnapshot.get("TripStatus");

        if (updatedStatus === "accepted") {
          console.log("Driver accepted the trip!");
          return { status: "accepted" };
        }

        if (updatedStatus !== tripId) {
          console.log("Driver status changed to something else. Ending early.");
          break;
        }
      }

      await driverRef.update({ TripStatus: "cancelled" });
      return { status: "timeout" };
    }

    return {
      status: "skipped",
      reason: "Driver already on another trip",
    };
  } catch (error) {
    console.error("Error in notifyDriverAndWait:", error);
    throw new functions.https.HttpsError("internal", "Function failed", error);
  }
});