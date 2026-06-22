import * as functions from "firebase-functions";
import { admin } from "../config/firebaseAdmin";

const db = admin.firestore();
const messaging = admin.messaging();

const ONLINE_DRIVER_REFS: Record<string, string> = {
  Bike: "online_bike_driver",
  Car: "online_car_driver",
  Auto: "online_auto_driver",
};

export const assignDriverToTrip = functions.https.onCall(async (data, context) => {
  const { tripId, userId, driverId, lat, lng } = data as {
    tripId: string;
    userId: string;
    driverId: string;
    lat: number;
    lng: number;
  };

  console.log("📦 Received data:", data);

  if (!tripId || !userId || !driverId || typeof lat !== "number" || typeof lng !== "number") {
    throw new functions.https.HttpsError("invalid-argument", "Missing or invalid parameters");
  }

  try {
    const tripRef = db.collection("trip_req").doc(tripId);
    const userRef = db.collection("users").doc(userId);
    const driverRef = db.collection("drivers").doc(driverId);

    // 🔍 Validate trip exists
    const tripSnap = await tripRef.get();
    if (!tripSnap.exists) {
      throw new functions.https.HttpsError("not-found", "trip_not_found");
    }

    // 🔍 Validate driver exists
    const driverSnap = await driverRef.get();
    if (!driverSnap.exists) {
      throw new functions.https.HttpsError("not-found", "driver_not_found");
    }

    const driverData = driverSnap.data();
    const currentTripStatus = driverData?.TripStatus;

    // ❌ Reject if driver's TripStatus doesn't match
    if (currentTripStatus !== tripId) {
      const errorCode =
        typeof currentTripStatus === "string" ? 
        currentTripStatus.toLowerCase():
         "trip_already_taken";

      throw new functions.https.HttpsError("failed-precondition", errorCode);
    }

    // 🚗 Resolve online collection path from vehicleType
    const vehicleType = driverData?.VehicleType as string | undefined;
    const onlinePath = vehicleType ? ONLINE_DRIVER_REFS[vehicleType] : null;

    // 🔄 Perform batch update
    const batch = db.batch();

    batch.update(tripRef, {
      StartTime: admin.firestore.FieldValue.serverTimestamp(),
      Status: "accepted",
      DriverId: driverId,
      DriverLocation: {
        latitude: lat,
        longitude: lng,
      },
    });

    batch.update(userRef, {
      TripStatus: tripId,
    });

    batch.update(driverRef, {
      TripStatus: "accepted",
      Status: tripId,
      isOnline: false,
    });

    // 🗑️ Remove driver from online collection if path is valid
    if (onlinePath) {
      const onlineDriverRef = db.collection(onlinePath).doc(driverId);
      batch.delete(onlineDriverRef);
      console.log(`🗑️ Removing driver from ${onlinePath}`);
    } else {
      console.warn(`⚠️ Unknown or missing vehicleType: "${vehicleType}", skipping online collection delete`);
    }

    await batch.commit();
    console.log("✅ Batch update complete");

    // 📲 Optional user notification if they have deviceToken
    const userSnap = await userRef.get();
    if (!userSnap.exists) {
      console.log("⚠️ User doc not found");
    } else {
      const userData = userSnap.data();
      const deviceToken = userData?.deviceToken;

      if (deviceToken) {
        const driverName = `${driverData?.firstName ?? ""} ${driverData?.lastName ?? ""}`.trim();
        const vehicleDetails = driverData?.VehicleDetails ?? "Vehicle";
        const numberPlate = driverData?.VehicleNumberPlate ?? "Number Plate";

        await messaging.send({
          token: deviceToken,
          notification: {
            title: "Driver Accepted Your Ride",
            body: `${driverName} (${vehicleDetails}, ${numberPlate}) is on the way`,
          },
          data: {
            type: "driver_accepted",
            tripId,
            driverId,
          },
        });

        console.log("📩 Notification sent to user");
      } else {
        console.log("📵 No deviceToken on user");
      }
    }

    return { success: true };
  } catch (error: any) {
    console.error("🔥 Error in assignDriverToTrip:", error);
    throw new functions.https.HttpsError(
      error.code || "internal",
      error.message || "failed_to_assign"
    );
  }
});