import * as functions from "firebase-functions";
import { admin } from "../config/firebaseAdmin";

const db = admin.firestore();

// configurable free trial (in months)
// set this to 0 to disable free trial without removing the function
const FREE_TRIAL_MONTHS = 0;

export const grantTrialSubscription = functions.https.onCall(async (data) => {
  const { uid } = data;

  if (!uid) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "User ID is required"
    );
  }

  const subsRef = db.collection("subscriptions").doc(uid);
  const subDoc = await subsRef.get();

  // if already has a subscription, just return existing state
    if (subDoc.exists) {
    return { success: true };
  }
  // ✅ create a trial subscription if FREE_TRIAL_MONTHS > 0
  if (FREE_TRIAL_MONTHS > 0) {
    const expiryDate = new Date();
    expiryDate.setMonth(expiryDate.getMonth() + FREE_TRIAL_MONTHS);

    const expiry = admin.firestore.Timestamp.fromDate(expiryDate);

    await subsRef.set({
      currentExpiry: expiry,
      active: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

     return { success: true };
  } 
});