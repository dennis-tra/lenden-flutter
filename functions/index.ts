import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as uuid from 'uuid';

const pairingsUserIdsField = "user_ids";

admin.initializeApp();

const firestore = admin.firestore();
firestore.settings({ timestampsInSnapshots: true });

exports.generateQRCodeOnUserCreation = functions.auth.user().onCreate(async (user) => {

    const userRef = firestore.collection("users").doc(user.uid);

    const userDoc = await userRef.get();
    if (userDoc.exists) {
        return
    }

    await userRef.create({
        qrCode: uuid.v4(),
        updateAt: admin.firestore.FieldValue.serverTimestamp(),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
    })

});

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

    // Check if the requesting user is already paired with another user different from the provided uid
    const pairingsOfPairer = await pairingsCol
        .where(`${pairingsUserIdsField}.${pairerUID}`, "==", true)
        .where(`${pairingsUserIdsField}.${paireeUID}`, "==", null)
        .get()

    if (!pairingsOfPairer.empty) {
        throw new functions.https.HttpsError(
            'failed-precondition',
            'You are already paired with another user.'
        );
    }

    const pairingsOfPairee = await pairingsCol
        .where(`${pairingsUserIdsField}.${paireeUID}`, "==", true)
        .where(`${pairingsUserIdsField}.${pairerUID}`, "==", null)
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