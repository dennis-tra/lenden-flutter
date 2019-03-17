import 'package:firebase_auth/firebase_auth.dart';
import 'package:lenden/store/auth/actions.dart';
import 'package:lenden/store/state.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

Epic<AppState> createAuthStateEpic({FirebaseAuth firebaseAuth}) {
  firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  return (Stream<dynamic> actions, EpicStore<AppState> store) {
    return Observable(actions)
        .ofType(TypeToken<StartObservingAuthState>())
        .switchMap((StartObservingAuthState action) {
      return Observable(firebaseAuth.onAuthStateChanged)
          .map((FirebaseUser user) => AuthStateChanged(user: user))
          .onErrorReturnWith((error) => AuthStateChanged(error: error))
          .takeUntil(
              actions.where((action) => action is StopObservingAuthState));
    });
  };
}
