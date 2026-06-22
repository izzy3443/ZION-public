import * as functions from "firebase-functions";
import { admin } from "../config/firebaseAdmin";
import axios from "axios";

const db = admin.firestore();
const messaging = admin.messaging();

interface Location {
  lat: number;
  lng: number;
}

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

export const handleDriverArrived = functions.https.onCall(
  async (data) => {
    const {
      tripId,
      userId,
      vehicleNumber,
      vehicleModel,
      otp,
      driverLocation, // { lat, lng }
      pickupLocation  // { lat, lng } of actual trip pickup point
    }: {
      tripId: string;
      userId: string;
      vehicleNumber: string;
      vehicleModel: string;
      otp: string;
      driverLocation: Location;
      pickupLocation: Location;
    } = data;

    // ✅ Input validation
    if (
      !tripId || !userId || !vehicleNumber || !vehicleModel || !otp ||
      !driverLocation || typeof driverLocation.lat !== "number" || typeof driverLocation.lng !== "number" ||
      !pickupLocation || typeof pickupLocation.lat !== "number" || typeof pickupLocation.lng !== "number"
    ) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing or invalid input fields"
      );
    }

    try {
      // ✅ Use Google Directions API to calculate distance to pickup point
      const apiKey = functions.config().maps.key;
      const directionsURL = `https://maps.googleapis.com/maps/api/directions/json?origin=${driverLocation.lat},${driverLocation.lng}&destination=${pickupLocation.lat},${pickupLocation.lng}&mode=driving&key=${apiKey}`;

      const directionsRes = await axios.get<GoogleDirectionsResponse>(directionsURL);
      const directionsData = directionsRes.data;

      if (directionsData.status !== "OK" || !directionsData.routes.length) {
        throw new functions.https.HttpsError("internal", "Failed to fetch directions from Google");
      }

      const leg = directionsData.routes[0].legs[0];
      const distanceMeters = leg.distance.value;

      // ❌ Too far from pickup point
      if (distanceMeters > 700) {
        console.warn("Driver too far from pickup point:", distanceMeters, "meters");
        return { status: "overlimit" };
      }

      // ✅ Proceed with marking arrived
      const tripRef = db.collection("trip_req").doc(tripId);
      await tripRef.update({
        Status: "arrived",
        ArrivedTime: admin.firestore.FieldValue.serverTimestamp(),
      });

      // ✅ Notify user
      const userDoc = await db.collection("users").doc(userId).get();
      const deviceToken = userDoc.get("deviceToken");

      if (deviceToken) {
        await messaging.send({
          token: deviceToken,
          notification: {
            title: "Your driver has arrived",
            body: `Vehicle: ${vehicleModel} (${vehicleNumber}), OTP: ${otp}`,
          },
          data: {
            tripId,
            type: "arrived",
          },
        });
      }

      return { status: "success"};

    } catch (error: any) {
      console.error("❌ Error in handleDriverArrived:", error);
      throw new functions.https.HttpsError(
        "internal",
        error.message || "Failed to mark driver as arrived"
      );
    }
  }
);