import 'package:lenden/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lenden/store/state.dart';
import 'package:lenden/store/auth/state.dart' as Auth;
import 'package:lenden/store/auth/actions.dart';
import 'package:lenden/store/user/actions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

Epic<AppState> userEpics() {
  return combineEpics(
      [userDataEpic, observeTokenRefreshEpic(), onTokenRefreshEpic()]);
}

Epic<AppState> observeTokenRefreshEpic({FirebaseMessaging firebaseMessaging}) {
  firebaseMessaging = firebaseMessaging ?? FirebaseMessaging();

  return (Stream<dynamic> actions, EpicStore<AppState> store) {
    return Observable(actions)
        .ofType(TypeToken<StartObservingFCMTokenRefresh>())
        .switchMap((StartObservingFCMTokenRefresh action) {
      return Observable(firebaseMessaging.onTokenRefresh)
          .map((token) => FCMTokenRefreshed(token: token))
          .onErrorReturnWith((error) => FCMTokenRefreshed(error: error))
          .takeUntil(actions
              .where((action) => action is StopObservingFCMTokenRefresh));
    });
  };
}

Epic<AppState> onTokenRefreshEpic(
    {Firestore firestore,
    FirebaseMessaging firebaseMessaging,
    FieldValue serverTimestamp}) {
  firestore = firestore ?? Firestore.instance;
  serverTimestamp = serverTimestamp ?? FieldValue.serverTimestamp();
  firebaseMessaging = firebaseMessaging ?? FirebaseMessaging();

  return (Stream<dynamic> actions, EpicStore<AppState> store) {
    final logInObservable = Observable(actions)
        .ofType(TypeToken<LogInCompleted>())
        .map((LogInCompleted login) => login.user)
        .startWith(store.state.auth.user);

    final logOutObservable = Observable(actions)
        .ofType(TypeToken<LogOutCompleted>())
        .where((action) => action.error == null)
        .map((_) => null);

    final userObservable =
        Observable.merge([logInObservable, logOutObservable]);

    final tokenRefreshObservable = Observable(actions)
        .ofType(TypeToken<FCMTokenRefreshed>())
        .where((action) => action.token != null)
        .map((action) => action.token);

    final firstTokenObservable =
        Observable.fromFuture(firebaseMessaging.getToken());

    final tokenObservable =
        Observable.merge([tokenRefreshObservable, firstTokenObservable]);

    return Observable.combineLatest2(userObservable, tokenObservable,
        (user, token) async {
      if (user == null) {
        return UserDataChanged(
            error: "could not update fcm token -> user possibly not logged in");
      }

      try {
        final ref = firestore.document("/users/${user.uid}");
        final userDoc = await ref.get();

        if (userDoc.exists) {
          final user = User.fromFirestore(userDoc);

          if (user.fcmToken != token) {
            await ref.updateData({
              "fcmToken": token,
              "updatedAt": serverTimestamp,
            });
          }
        } else {
          await ref.setData({
            "fcmToken": token,
            "subscription": {"numberPlate": null, "createdAt": null},
            "updatedAt": serverTimestamp,
            "createdAt": serverTimestamp
          });
        }
        return UserDataChanged(user: User.fromFirestore(userDoc));
      } catch (error) {
        print("error $error");
        return UserDataChanged(error: error);
      }
    }).switchMap((future) => Observable.fromFuture(future));
  };
}

Stream<UserDataChanged> userDataEpic(
    Stream<dynamic> actions, EpicStore<AppState> store) {
  return Observable(actions)
      .ofType(TypeToken<StartObservingUserData>())
      .switchMap((StartObservingUserData action) {
    var cachedUser = Observable.just(store.state.auth.user);

    var logInCompleted = Observable(actions)
        .ofType(TypeToken<LogInCompleted>())
        .map((LogInCompleted login) => login.user);

    var logOutCompleted = Observable(actions)
        .ofType(TypeToken<LogOutCompleted>())
        .where((LogOutCompleted logout) => logout.error == null)
        .map((LogOutCompleted logout) => null);

    return Observable.merge([cachedUser, logInCompleted, logOutCompleted])
        .switchMap((FirebaseUser user) {
      if (user == null) {
        switch (store.state.auth.status) {
          case Auth.Status.LoggedIn:
            return Observable.just(UserDataChanged(error: "Unknown error"));
          case Auth.Status.LoggedOut:
            return Observable.just(
                UserDataChanged(error: "User is logged out"));
          case Auth.Status.Unknown:
            return Observable.just(
                UserDataChanged(error: "User auth state unknown"));
        }
      }

      return Observable(
              Firestore.instance.document("users/${user.uid}").snapshots())
          .map(User.fromFirestore)
          .map((User user) => UserDataChanged(user: user))
          .onErrorReturnWith((error) => UserDataChanged(error: error))
          .takeUntil(
              actions.where((action) => action is StopObservingUserData));
    }).takeUntil(actions.where((action) => action is StopObservingUserData));
  });
}
