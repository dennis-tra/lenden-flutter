import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const pairingsUserIdsField = "user_ids";

admin.initializeApp();

const firestore = admin.firestore();
firestore.settings({ timestampsInSnapshots: true });

exports.pairUsers = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    console.error("The pairing function must be called while authenticated.");

    throw new functions.https.HttpsError(
      "failed-precondition",
      "The pairing function must be called while authenticated."
    );
  }

  // the user who has initiated the pairing process
  const pairerUID = context.auth.uid;

  // the user who should be paired to the pairer
  const paireeUID = data.uid;

  if (!(typeof paireeUID === "string") || paireeUID.length === 0) {
    console.error(
      'The function must be called with one arguments "uid" containing the user id of the user you want to pair with.'
    );

    throw new functions.https.HttpsError(
      "invalid-argument",
      'The function must be called with one arguments "uid" containing the user id of the user you want to pair with.'
    );
  }

  if (pairerUID === paireeUID) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "You cannot be paired with yourself."
    );
  }

  try {
    await admin.auth().getUser(paireeUID);
  } catch (error) {
    console.error(
      "The provided user id could not be retrieved or found in the database."
    );

    throw new functions.https.HttpsError(
      "not-found",
      "The provided user id could not be retrieved or found in the database."
    );
  }

  const pairingsCol = firestore.collection("pairings");

  // Check if the requesting users are already paired; if yes, answer idempotent with success
  const pairings = await pairingsCol
    .where(`${pairingsUserIdsField}.${pairerUID}`, "==", true)
    .where(`${pairingsUserIdsField}.${paireeUID}`, "==", true)
    .get();

  if (!pairings.empty) {
    return pairings.docs[0];
  }

  // Check if the requesting user is already paired with another user.
  // If the user has a pairing with pairee we had returned above.
  const pairingsOfPairer = await pairingsCol
    .where(`${pairingsUserIdsField}.${pairerUID}`, "==", true)
    .get();

  if (!pairingsOfPairer.empty) {
    console.error("You are already paired with another user.");

    throw new functions.https.HttpsError(
      "failed-precondition",
      "You are already paired with another user."
    );
  }

  const pairingsOfPairee = await pairingsCol
    .where(`${pairingsUserIdsField}.${paireeUID}`, "==", true)
    .get();

  if (!pairingsOfPairee.empty) {
    console.error(
      "The user you want to be paired with is already paired with another user."
    );

    throw new functions.https.HttpsError(
      "failed-precondition",
      "The user you want to be paired with is already paired with another user."
    );
  }

  const pairing = await pairingsCol.add({
    [pairingsUserIdsField]: {
      [pairerUID]: true,
      [paireeUID]: true
    }
  });

  return pairing.get();
});

exports.sendPushNotification = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "The pairing function must be called while authenticated."
    );
  }

  // the user who has initiated the pairing process
  const senderUID = context.auth.uid;

  const pairingsCol = firestore.collection("pairings");

  // Check if the requesting users are already paired; if yes, answer idempotent with success
  const pairings = await pairingsCol
    .where(`${pairingsUserIdsField}.${senderUID}`, "==", true)
    .get();

  if (pairings.empty) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "You are not paired to any other user."
    );
  }

  if (pairings.docs.length > 1) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "You are paired to more than one user."
    );
  }

  try {
    const pairing = pairings.docs[0].data();

    const sendees: Array<string> = Object.keys(
      pairing[pairingsUserIdsField]
    ).filter(k => k !== senderUID);

    if (sendees.length !== 1) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "You are paired to more than one user."
      );
    }

    const sendee = sendees[0];

    const userDoc = await firestore.doc(`users/${sendee}`).get();
    const user = userDoc.data();

    if (sendees.length !== 1) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "You are paired to more than one user."
      );
    }

    const message = {
      notification: {
        title: "🍺🍺🍺🍺🍺🍺",
        sound: "plop.mp3"
      }
    };

    const response = await admin
      .messaging()
      .sendToDevice(user["fcmToken"], message);
  } catch (error) {
    throw new functions.https.HttpsError(
      "internal",
      `Could not send message: ${error}`
    );
  }
});
