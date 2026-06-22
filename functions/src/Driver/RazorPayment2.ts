import * as functions from "firebase-functions";
import { admin } from "../config/firebaseAdmin";
import Razorpay from "razorpay";
import * as crypto from "crypto";


const keyId = functions.config().razorpay.key;
const keySecret   = functions.config().razorpay.secret;

const razorpay = new Razorpay({ key_id: keyId, key_secret: keySecret });

const PRODUCTS: Record<string, { name: string; amountPaise: number; currency: "INR" }> = {
  COFFEE_99: { name: "Coffee", amountPaise: 9900, currency: "INR" },
  PLUS_199: { name: "Plus Plan", amountPaise: 19900, currency: "INR" },
};

export const createRazorpayOrderSecure = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid || null;
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

  await admin.firestore().collection("payments").doc(order.id).set(
    {
      status: "created",
      amount: order.amount,
      currency: order.currency,
      receipt: order.receipt,
      sku,
      uid,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );

  return {
    orderId: order.id,
    amount: order.amount,
    currency: order.currency,
    keyId: keyId, // safe to expose to client
    name: product.name,
  };
});

export const verifyRazorpaySignature = functions.https.onCall(async (data, context) => {
  const orderId = data.orderId as string;
  const paymentId = data.paymentId as string;
  const signature = data.signature as string;
  const uid = context.auth?.uid || null;

  if (!orderId || !paymentId || !signature) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "orderId, paymentId, signature are required"
    );
  }

  // ✅ Generate expected HMAC
  const expected = crypto
    .createHmac("sha256", keySecret)
    .update(`${orderId}|${paymentId}`)
    .digest("hex");

  const verified = expected === signature;
  const ref = admin.firestore().collection("payments").doc(orderId);

  if (verified) {
    await ref.set(
      {
        status: "paid",
        paymentId,
        signature,
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        uid,
      },
      { merge: true }
    );
  } else {
    await ref.set(
      {
        status: "signature_mismatch",
        paymentId,
        signature,
        checkedAt: admin.firestore.FieldValue.serverTimestamp(),
        uid,
      },
      { merge: true }
    );
  }

  return { verified };
});