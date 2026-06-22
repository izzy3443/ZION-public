import * as functions from "firebase-functions";

export const PriceCalculation = functions.https.onCall((data) => {
  const { distanceMeters, durationSeconds } = data;

  if (
    typeof distanceMeters !== "number" ||
    typeof durationSeconds !== "number"
  ) {
    throw new functions.https.HttpsError("invalid-argument", "Invalid input");
  }

  const fare = {
    bike: calculate(distanceMeters, durationSeconds, 0.4, 0.3),
    car: calculate(distanceMeters, durationSeconds, 0.4, 0.7),
    auto: calculate(distanceMeters, durationSeconds, 0.5, 0.4),
  };

  return fare;
});

function calculate(
  distanceMeters: number,
  durationSeconds: number,
  distanceRate: number,
  durationRate: number
): number {
  const distanceKm = distanceMeters / 1000;
  const durationMin = durationSeconds / 60;
  const baseFare = 2;

  const total =
    baseFare + distanceKm * distanceRate + durationMin * durationRate;
  return parseFloat(total.toFixed(2));
}

