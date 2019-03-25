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
            .where((QuerySnapshot q) => q.documents.length == 1)
            .map((QuerySnapshot q) => q.documents[0])
            .map(Pairing.fromFirestore)
            .map((Pairing pairing) => PairingStateChanged(pairing: pairing))
            .onErrorReturnWith((error) => PairingStateChanged(error: error))
            .takeUntil(actions.where((action) =>
                action is StopObservingPairingState ||
                (action is AuthStateChanged && action.user == null)));
      }).takeUntil(
              actions.where((action) => action is StopObservingPairingState));
    });
  };
}
