import * as functions from "firebase-functions";
import { admin } from "../config/firebaseAdmin";


export const StartDestAddRecentPlaces = functions.https.onCall(async (data, _context) => {
    const { userId, address } = data;
  
    if (!userId || typeof userId !== "string" || !address || typeof address !== "object") {
      throw new functions.https.HttpsError("invalid-argument", "Invalid input data.");
    }
  
    const docRef = admin.firestore().collection("users").doc(userId);
  
    try {
      const doc = await docRef.get();
      const docData = doc.data();
      let recentPlaces: { place_id: string; [key: string]: any }[] = [];
  
      if (doc.exists && docData != null) { 
        recentPlaces = Array.isArray(docData.RecentPlaces) ? docData.RecentPlaces : [];
  
        // Check if the address already exists
        recentPlaces = recentPlaces.filter((place) => place.place_id !== address.place_id);
  
        // Insert new place at the start
        recentPlaces.unshift(address);
  
        // Limit to 5 places
        if (recentPlaces.length > 5) {
          recentPlaces = recentPlaces.slice(0, 5);
        }
  
        // Update Firestore
        await docRef.update({ RecentPlaces: recentPlaces });
  
        return { status: "success" };
      } else {
        throw new functions.https.HttpsError("not-found", "User not found.");
      }
  
    } catch (error) {
      console.error("Error updating recent places:", error);
      throw new functions.https.HttpsError("internal", "Failed to update recent places.");
    }
  });