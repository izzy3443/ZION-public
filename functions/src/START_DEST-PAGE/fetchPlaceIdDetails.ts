import * as functions from "firebase-functions";
import axios from "axios";

/* -------------------------------------------------------------------------- */
/*                                  TYPES                                     */
/* -------------------------------------------------------------------------- */

interface GooglePlaceDetailsResponse {
  status: string;
  result: {
    name: string;
    geometry: {
      location: {
        lat: number;
        lng: number;
      };
    };
  };
}

interface AddressModel {
  lat: number;
  long: number;
  Place_name: string;
  Place_name_sec: string;
  place_id: string;
}

/* -------------------------------------------------------------------------- */
/*                             CLOUD FUNCTION                                 */
/* -------------------------------------------------------------------------- */

export const fetchPlaceIdDetails = functions.https.onCall(
  async (data, context): Promise<AddressModel> => {

    /* ----------------------------- Auth check ----------------------------- */
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated."
      );
    }

    /* --------------------------- Validate input --------------------------- */
    const { placeId, secText } = data;

    if (!placeId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Invalid place id."
      );
    }

    /* ------------------------- Secure API key load ------------------------ */
    const apiKey = functions.config().maps.key;

    const url =
      `https://maps.googleapis.com/maps/api/place/details/json` +
      `?place_id=${placeId}&key=${apiKey}`;

    try {
      /* -------------------- TYPED AXIOS CALL (FIX HERE) -------------------- */
      const response =
        await axios.get<GooglePlaceDetailsResponse>(url);

      const res = response.data;

      const status = res.status;

      /* ----------------------- Same Dart error logic ----------------------- */
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

      /* --------------------------- Parse result ---------------------------- */
      const result = res.result;

      return {
        lat: result.geometry.location.lat,
        long: result.geometry.location.lng,
        Place_name: result.name,
        Place_name_sec: secText,
        place_id: placeId,
      };

    } catch (err) {
      console.error("Place details error:", err);

      throw new functions.https.HttpsError(
        "unavailable",
        "Something went wrong. Please try again later."
      );
    }
  }
);