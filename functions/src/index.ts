import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
admin.firestore().settings({ timestampsInSnapshots: true });

exports.sendNewReportNotification2 = functions.firestore.document('reports/{reportId}').onCreate(async (snapshot, event) => {
    const reportId = event.params.reportId;

    console.log('Report to send notification to report id: ', reportId);

    const numberPlate = snapshot.data()["numberPlate"]

    console.log('To number plate', numberPlate, snapshot.data());

    const qs = await admin.firestore()
        .collection('users')
        .where('subscription.numberPlate', '==', numberPlate)
        .get();

    qs.forEach(doc => {
        const message = {
            notification: {
                title: 'You have a new notification',
                body: snapshot.data()["message"]
            },
            token: doc.data()["fcmToken"],
        };

        admin.messaging().send(message).then(s => console.log(s)).catch(s => console.error(s));
    });
})