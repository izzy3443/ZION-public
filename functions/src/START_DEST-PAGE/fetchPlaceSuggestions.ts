import * as functions from "firebase-functions";
import axios from "axios";

interface GooglePlaceAutocompleteResponse {
  status: string;
  predictions: any[]; 
}


export const fetchPlaceSuggestions = functions.https.onCall(
  async (data, context): Promise<any[]> => {

    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated."
      );
    }

    const { input } = data;

    if (!input || input.length < 2) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Please enter more than 2 letters."
      );
    }

    const apiKey = functions.config().maps.key;

    const url =
      `https://maps.googleapis.com/maps/api/place/autocomplete/json` +
      `?input=${encodeURIComponent(input)}` +
      `&key=${apiKey}` +
      `&components=country:in` +
      `&location=17.4065,78.4772` +
      `&radius=177000`;

    try {
      const response =
        await axios.get<GooglePlaceAutocompleteResponse>(url);

      const res = response.data;

      const status = res.status;

      if (status !== "OK") {
        switch (status) {
          case "REQUEST_DENIED":
            throw new functions.https.HttpsError(
              "permission-denied",
              "API request denied. Check API key or billing."
            );

          case "OVER_QUERY_LIMIT":
            throw new functions.https.HttpsError(
              "resource-exhausted",
              "You have exceeded the request limit. Try again later."
            );

          case "NOT_FOUND":
            throw new functions.https.HttpsError(
              "not-found",
              "Place not found."
            );

          case "ZERO_RESULTS":
            throw new functions.https.HttpsError(
              "not-found",
              "No places found."
            );

          case "INVALID_REQUEST":
            throw new functions.https.HttpsError(
              "invalid-argument",
              "Invalid request sent to Google."
            );

          default:
            throw new functions.https.HttpsError(
              "internal",
              "Something went wrong. Please try again."
            );
        }
      }

      return res.predictions;

    } catch (err) {
      console.error("Places autocomplete error:", err);

      throw new functions.https.HttpsError(
        "unavailable",
        "Something went wrong. Please try again."
      );
    }
  }
);