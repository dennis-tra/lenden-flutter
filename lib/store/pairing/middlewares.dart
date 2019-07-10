import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:redux/redux.dart';

import 'package:lenden/store/pairing/actions.dart';
import 'package:lenden/store/pairing/state.dart';
import 'package:lenden/store/state.dart';

List<Middleware<AppState>> createPairingMiddleware(
    {CloudFunctions cloudFunctions, Firestore firestore}) {
  cloudFunctions = cloudFunctions ?? CloudFunctions.instance;
  firestore = firestore ?? Firestore.instance;

  return [
    TypedMiddleware<AppState, Pair>(_pairMiddleware(cloudFunctions)),
    TypedMiddleware<AppState, Unpair>(_unpairMiddleware(firestore)),
  ];
}

_pairMiddleware(CloudFunctions cloudFunctions) {
  return (Store<AppState> store, Pair action, NextDispatcher next) {
    var process = store.state.pairing.process;
    if (process == Process.Settled) {
      final pairingData = {"uid": action.uid};

      CloudFunctions.instance.getHttpsCallable(functionName: 'pairUsers')
          .call([pairingData])
          .then((dynamic response) {
        final _firebaseMessaging = FirebaseMessaging();
        _firebaseMessaging.configure(
          onMessage: (Map<String, dynamic> message) async {
            print('on message $message');
          },
          onResume: (Map<String, dynamic> message) async {
            print('on resume $message');
          },
          onLaunch: (Map<String, dynamic> message) async {
            print('on launch $message');
          },
        );
        _firebaseMessaging.requestNotificationPermissions(
            IosNotificationSettings(sound: true, badge: true, alert: true));
        _firebaseMessaging.onIosSettingsRegistered
            .listen((IosNotificationSettings settings) {
          print("Settings registered: $settings");
        });
        store.dispatch(PairCompleted());
      }).catchError((error) {
        store.dispatch(PairCompleted(error: error));
      });
    }

    next(action);
  };
}

_unpairMiddleware(Firestore firestore) {
  return (Store<AppState> store, Unpair action, NextDispatcher next) {
    var process = store.state.pairing.process;
    if (process == Process.Settled) {
      firestore
          .collection("pairings")
          .where("user_ids.${store.state.auth.user.uid}", isEqualTo: true)
          .getDocuments()
          .then((docs) async {
        try {
          docs.documents.forEach((snapshot) async {
            await snapshot.reference.delete();
          });
          store.dispatch(UnpairCompleted());
        } catch (error) {
          store.dispatch(UnpairCompleted(error: error));
        }
      }).catchError((error) {
        store.dispatch(UnpairCompleted(error: error));
      });
    }

    next(action);
  };
}
