import * as functions from "firebase-functions";
import { admin } from "../config/firebaseAdmin";

const db = admin.firestore();
export const checkSubscription = functions.https.onCall(async (data) => {
  const { uid } = data;

  if (!uid) {
    throw new functions.https.HttpsError("invalid-argument", "User ID is required");
  }

  const subDoc = await db.collection("subscriptions").doc(uid).get();

  if (!subDoc.exists) {
    // no subscription created yet
    return {
      expiry: null,
      active: false,
    };
  }

  const expiry = subDoc.get("currentExpiry");
  if (!expiry) {
    // doc exists but expiry not set (maybe created but not paid)
    return {
      expiry: null,
      active: false,
    };
  }

  const now = admin.firestore.Timestamp.now();
  const active = expiry.toMillis() > now.toMillis();

  return {
    expiry: expiry.toDate().toISOString(),
    active,
  };
});