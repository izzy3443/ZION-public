import * as functions from "firebase-functions";
import { notifyDriverAndWait } from "./RIDE-PAGE/driverNotification";
import { PriceCalculation } from "./PRICE-PAGE/PriceCalculation";
import { StartDestAddRecentPlaces } from "./START_DEST-PAGE/StartDest-AddToRecentRides";
import { rideOptionsAndAddressModel } from "./PRICE-PAGE/getRideOptionsAndAddressModel";
import { endTrip } from "./Driver/endtrip";
import { submitTripRating } from "./RIDE-PAGE/submitTripRating";
import { assignDriverToTrip } from "./Driver/assignDriverToTrip";
import { cancelTrip } from "./RIDE-PAGE/cancelTrip";
import { handleDriverArrived } from "./RIDE-PAGE/handleDriverArrived";
import { handleTripPickup } from "./RIDE-PAGE/handleTripPickup";
import { createRazorpayOrderSecure, verifyRazorpaySignature } from "./Driver/RazorPayment2";
import { createRazorpayOrder, verifyRazorpaySign } from "./Driver/razorPaymentGate";
import {checkSubscription } from "./Driver/checkSubscription";
import {grantTrialSubscription } from "./Driver/grantTrial";
import { fetchPlaceIdDetails } from "./START_DEST-PAGE/fetchPlaceIdDetails";
import { fetchPlaceSuggestions } from "./START_DEST-PAGE/fetchPlaceSuggestions";
import { getDirectionDetailsFromApi } from "./START_DEST-PAGE/getDirectionDetailsFromApi";
import { convertGeoToHumanReadable } from "./START_DEST-PAGE/convertGeoToHumanReadable";

export const helloWorld = functions.https.onCall(() => {
  return { message: "Hello, World!" };
});

export {
  convertGeoToHumanReadable,
  getDirectionDetailsFromApi,
  fetchPlaceSuggestions,
  fetchPlaceIdDetails,
  grantTrialSubscription,
  checkSubscription,
  handleTripPickup,
  handleDriverArrived,
  cancelTrip,
  assignDriverToTrip,
  submitTripRating,
  endTrip,
  rideOptionsAndAddressModel,
  notifyDriverAndWait,
  PriceCalculation,
  StartDestAddRecentPlaces,
  createRazorpayOrderSecure,
  verifyRazorpaySignature,
  createRazorpayOrder, 
  verifyRazorpaySign
};

