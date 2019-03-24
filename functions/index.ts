import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const pairingsUserIdsField = "user_ids";

admin.initializeApp();

const firestore = admin.firestore();
firestore.settings({ timestampsInSnapshots: true });

exports.pairUsers = functions.https.onCall(async (data, context) => {

    if (!context.auth) {
        throw new functions.https.HttpsError(
            'failed-precondition',
            'The pairing function must be called while authenticated.'
        );
    }

    // the user who has initiated the pairing process
    const pairerUID = context.auth.uid

    // the user who should be paired to the pairer
    const paireeUID = data.uid

    if (!(typeof paireeUID === 'string') || paireeUID.length === 0) {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'The function must be called with one arguments "uid" containing the user id of the user you want to pair with.'
        );
    }

    try {
        await admin.auth().getUser(paireeUID)
    } catch (error) {
        throw new functions.https.HttpsError(
            'not-found',
            'The provided user id could not be retrieved or found in the database.'
        );
    }

    const pairingsCol = firestore.collection("pairings");

    // Check if the requesting users are already paired; if yes, answer idempotent with success
    const pairings = await pairingsCol
        .where(`${pairingsUserIdsField}.${pairerUID}`, "==", true)
        .where(`${pairingsUserIdsField}.${paireeUID}`, "==", true)
        .get()

    if (!pairings.empty) {
        return pairings.docs[0]
    }

    // Check if the requesting user is already paired with another user.
    // If the user has a pairing with pairee we had returned above.
    const pairingsOfPairer = await pairingsCol
        .where(`${pairingsUserIdsField}.${pairerUID}`, "==", true)
        .get()

    if (!pairingsOfPairer.empty) {
        throw new functions.https.HttpsError(
            'failed-precondition',
            'You are already paired with another user.'
        );
    }

    const pairingsOfPairee = await pairingsCol
        .where(`${pairingsUserIdsField}.${paireeUID}`, "==", true)
        .get()

    if (!pairingsOfPairee.empty) {
        throw new functions.https.HttpsError(
            'failed-precondition',
            'The user you want to be paired with is already paired with another user.'
        );
    }

    return await pairingsCol.add({
        [pairingsUserIdsField]: {
            [pairerUID]: true,
            [paireeUID]: true,
        }
    })
});