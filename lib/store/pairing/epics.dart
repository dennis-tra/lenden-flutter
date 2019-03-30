import 'package:lenden/store/state.dart';
import 'package:lenden/models/pairing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lenden/store/auth/actions.dart';
import 'package:lenden/store/pairing/actions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

Epic<AppState> pairingEpics() {
  return combineEpics([observePairingStateEpic()]);
}

Epic<AppState> observePairingStateEpic({Firestore firestore}) {
  firestore = firestore ?? Firestore.instance;

  return (Stream<dynamic> actions, EpicStore<AppState> store) {
    return Observable(actions)
        .ofType(TypeToken<StartObservingPairingState>())
        .switchMap((StartObservingPairingState action) {
      final cachedUser = Observable.just(store.state.auth.user)
          .where((FirebaseUser user) => user != null);

      final authStateChanged = Observable(actions)
          .ofType(TypeToken<AuthStateChanged>())
          .where((AuthStateChanged a) => a.user != null)
          .map((AuthStateChanged a) => a.user);

      return Observable.merge([cachedUser, authStateChanged])
          .switchMap((FirebaseUser user) {
        return Observable(Firestore.instance
                .collection("pairings")
                .where("user_ids.${user.uid}", isEqualTo: true)
                .snapshots())
            .map((QuerySnapshot q) {
              final pairingsCount = q.documents.length;

              if (pairingsCount == 1) {
                final pairing = Pairing.fromFirestore(q.documents[0]);
                if (pairing.userIds.length == 2) {
                  return PairingStateChanged(pairing: pairing);
                } else {
                  final e = "Found pairing with unsupported amount of user ids";
                  return PairingStateChanged(error: e);
                }
              } else if (pairingsCount > 1) {
                return PairingStateChanged(
                    error: "Found ${q.documents.length} pairings");
              } else {
                return PairingStateChanged();
              }
            })
            .onErrorReturnWith((error) => PairingStateChanged(error: error))
            .takeUntil(
                actions.where((action) => action is StopObservingPairingState));
      }).takeUntil(
              actions.where((action) => action is StopObservingPairingState));
    });
  };
}
