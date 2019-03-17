import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lenden/store/auth/actions.dart';
import 'package:lenden/store/auth/state.dart';
import 'package:lenden/store/state.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:redux/redux.dart';

List<Middleware<AppState>> createAuthMiddleware({FirebaseAuth firebaseAuth}) {
  firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  return [
    TypedMiddleware<AppState, LogIn>(_logInMiddleware(firebaseAuth)),
    TypedMiddleware<AppState, LogOut>(_logOutMiddleware(firebaseAuth)),
  ];
}

_logInMiddleware(FirebaseAuth firebaseAuth) {
  return (Store<AppState> store, LogIn action, NextDispatcher next) {
    var process = store.state.auth.process;
    if (process == Process.Settled || process == Process.Failed) {
      firebaseAuth.signInAnonymously().then((FirebaseUser user) {
        store.dispatch(LogInCompleted(user: user));
      }).catchError((error) {
        store.dispatch(LogInCompleted(error: error));
      });
    }

    next(action);
  };
}

_logOutMiddleware(FirebaseAuth firebaseAuth) {
  return (Store<AppState> store, LogOut action, NextDispatcher next) {
    var process = store.state.auth.process;
    if (process == Process.Settled || process == Process.Failed) {
      FirebaseAuth.instance.signOut().then((_) {
        store.dispatch(LogOutCompleted());
      }).catchError((error) {
        store.dispatch(LogOutCompleted(error: error));
      });
    }

    next(action);
  };
}
