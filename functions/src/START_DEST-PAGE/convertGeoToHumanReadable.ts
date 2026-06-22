import * as functions from "firebase-functions";
import axios from "axios";


interface GoogleGeocodeResponse {
  status: string;
  results: {
    formatted_address: string;
  }[];
}

interface ReverseGeocodeResult {
  placeName: string;
  lat: number;
  lng: number;
}

export const convertGeoToHumanReadable = functions.https.onCall(
  async (data, context): Promise<ReverseGeocodeResult> => {

    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated."
      );
    }

    /* --------------------------- Validate input --------------------------- */
    const { lat, lng } = data;

    if (typeof lat !== "number" || typeof lng !== "number") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Invalid latitude or longitude."
      );
    }

    /* ------------------------- Secure API key load ------------------------ */

    const apiKey = functions.config().maps.key;

    const geoApiUrl =
      `https://maps.googleapis.com/maps/api/geocode/json` +
      `?latlng=${lat},${lng}&key=${apiKey}`;

    try {
      /* ------------------ Typed axios call (fixes TS error) ------------------ */
      const response =
        await axios.get<GoogleGeocodeResponse>(geoApiUrl);

      const responseFromApi = response.data;

      const status = responseFromApi.status;

      /* ----------------------- Same Dart error logic ----------------------- */
      if (status !== "OK") {
        switch (status) {
          case "ZERO_RESULTS":
            throw new functions.https.HttpsError(
              "not-found",
              "No address found for this location."
            );

          case "REQUEST_DENIED":
            throw new functions.https.HttpsError(
              "permission-denied",
              "Request denied. Please check your API key or permissions."
            );

          case "OVER_QUERY_LIMIT":
            throw new functions.https.HttpsError(
              "resource-exhausted",
              "Too many requests. Try again later."
            );

          default:
            throw new functions.https.HttpsError(
              "internal",
              "Failed fetching address"
            );
        }
      }

      /* ---------------------------- Parse result --------------------------- */
      if (responseFromApi.results?.length) {
        return {
          placeName: responseFromApi.results[0].formatted_address,
          lat,
          lng,
        };
      }

      throw new functions.https.HttpsError(
        "not-found",
        "No address data found."
      );

    } catch (error) {
      console.error("Reverse geocode error:", error);

      throw new functions.https.HttpsError(
        "unavailable",
        "Weak internet connection. Failed to fetch address."
      );
    }
  }
);