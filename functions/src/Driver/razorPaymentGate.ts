import * as functions from "firebase-functions";
import { admin } from "../config/firebaseAdmin";
import Razorpay from "razorpay";
import * as crypto from "crypto";


const keyId = functions.config().razorpay.key;
const keySecret   = functions.config().razorpay.secret;

const razorpay = new Razorpay({ key_id: keyId, key_secret: keySecret });

const PRODUCTS: Record<string, { name: string; amountPaise: number; currency: "INR" }> = {
  COFFEE_99: { name: "Coffee", amountPaise: 990, currency: "INR" },
  PLUS_199: { name: "Plus Plan", amountPaise: 1990, currency: "INR" },
  AUTO_1M: { name: "1 Month Auto", amountPaise: 900, currency: "INR" },  // 49900
  CAR_1M: { name: "1 Month Cab", amountPaise: 900, currency: "INR" },  // 99900
};

export const createRazorpayOrder = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError("unauthenticated", "User must be logged in");
  }

  const sku = (data.sku as string) || "";
  const product = PRODUCTS[sku];
  if (!product) {
    throw new functions.https.HttpsError("invalid-argument", "Unknown SKU");
  }

  const receipt = `rcpt_${Date.now()}`;
  const notes = { sku, uid };

  const order: any = await razorpay.orders.create({
    amount: product.amountPaise,
    currency: product.currency,
    receipt,
    notes,
  });

  const subsRef = admin.firestore().collection("subscriptions").doc(uid);

  // record in history as "created" (not yet paid)
  await subsRef.collection("grantTrialSubscription").doc(order.id).set({
    orderId: order.id,
    status: "created", // initial
    amount: product.amountPaise,
    currency: product.currency,
    sku,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {
    orderId: order.id,
    amount: order.amount,
    currency: order.currency,
    keyId: keyId,
    name: product.name,
  };
});

export const verifyRazorpaySign = functions.https.onCall(async (data, context) => {
  const orderId = data.orderId as string;
  const paymentId = data.paymentId as string;
  const signature = data.signature as string;
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError("unauthenticated", "User must be logged in");
  }

  if (!orderId || !paymentId || !signature) {
    throw new functions.https.HttpsError("invalid-argument", "orderId, paymentId, signature required");
  }

  const expected = crypto
    .createHmac("sha256", keySecret)
    .update(`${orderId}|${paymentId}`)
    .digest("hex");

  const verified = expected === signature;

  const subsRef = admin.firestore().collection("subscriptions").doc(uid);

  if (verified) {
    // new expiry (+30 days)
    const expiry = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
    );

    // ✅ update current subscription doc
    await subsRef.set(
      {
        currentExpiry: expiry,
        active: true,
      },
      { merge: true }
    );

    // ✅ mark this order as successful in history
    await subsRef.collection("history").doc(orderId).set(
      {
        paymentId,
        signature,
        status: "paid",
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        expiry,
      },
      { merge: true }
    );
  } else {
    // ❌ mark this order as failed
    await subsRef.collection("history").doc(orderId).set(
      {
        paymentId,
        signature,
        status: "failed",
        checkedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  }

  return { verified };
});