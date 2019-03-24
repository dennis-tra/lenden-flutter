import 'dart:async';

import 'package:lenden/store/auth/actions.dart';
import 'package:lenden/store/reducers.dart';
import 'package:lenden/store/auth/state.dart';
import 'package:lenden/store/state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mockito/mockito.dart';

import 'package:lenden/store/user/actions.dart';
import 'package:lenden/store/user/epics.dart';
import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';

class FirebaseMessagingMock extends Mock implements FirebaseMessaging {}
class FirestoreMock extends Mock implements Firestore {}
class FirebaseUserMock extends Mock implements FirebaseUser {}
class DocumentReferenceMock extends Mock implements DocumentReference {}
class DocumentSnapshotMock extends Mock implements DocumentSnapshot {}
class FieldValueMock extends Mock implements FieldValue {}

StreamController getStream(Iterable elements) {
  // ignore: close_sinks
  final streamController = StreamController.broadcast(sync: true);
  streamController.onListen = () => elements.forEach((e) => streamController.add(e));

  return streamController;
}

main() {

  group('observeTokenRefreshEpic', () {
    final firebaseMessaging = FirebaseMessagingMock();
    final epic = observeTokenRefreshEpic(firebaseMessaging: firebaseMessaging);

    mockOnTokenRefreshWithAnswers(Iterable<String> elements) {
      when(firebaseMessaging.onTokenRefresh).thenAnswer((_) => Stream.fromIterable(elements));
    }

    mockOnTokenRefreshWithError(dynamic throwable) {
      when(firebaseMessaging.onTokenRefresh).thenAnswer((_) => Stream.fromFuture(Future.error(throwable)));
    }

    test('if epic emits an FCMTokenRefreshed action when a new token arrives', () async {
      final testToken = "TEST_TOKEN";
      mockOnTokenRefreshWithAnswers([testToken]);
      final actions = getStream([StartObservingFCMTokenRefresh()]);
      await expectLater(epic(actions.stream, null), emits(FCMTokenRefreshed(token: testToken)));
      actions.close();
    });


    test('if epic an FCMTokenRefreshed action in an error case', () async {
      final expectedError = "ERROR";
      mockOnTokenRefreshWithError(expectedError);
      final actions = getStream([StartObservingFCMTokenRefresh()]);
      await expectLater(epic(actions.stream, null), emitsInOrder([FCMTokenRefreshed(error: expectedError)]));
      actions.close();
    });

    test('if multiple token refresh result in multiple FCMTokenRefreshed actions', () async {
      final tokens = ["token1", "token2", "token3", "token4"];
      mockOnTokenRefreshWithAnswers(tokens);
      final actions = getStream([StartObservingFCMTokenRefresh()]);
      final expectedEvents = tokens.map((t) => FCMTokenRefreshed(token: t));
      await expectLater(epic(actions.stream, null), emitsInOrder(expectedEvents));
      actions.close();
    });
  });


  group('onTokenRefreshEpic', () {
    final firestore = FirestoreMock();
    final user = FirebaseUserMock();
    final ref = DocumentReferenceMock();
    final doc = DocumentSnapshotMock();
    final firebaseMessagingMock = FirebaseMessagingMock();
    final userId = "test uid";
    final timestamp = FieldValue.serverTimestamp();

    when(firebaseMessagingMock.getToken()).thenAnswer((_) => Future.value("token"));
    when(user.uid).thenReturn(userId);
    when(firestore.document("/users/$userId")).thenReturn(ref);
    when(ref.get()).thenAnswer((_) => Future.value(doc));

    test('if user is logged in and already created the fcm token is updated', () async {
      final data = {
        "fcmToken": "TEST_TOKEN",
        "updatedAt":timestamp,
      };

      when(doc.exists).thenReturn(true);
      when(ref.updateData(data)).thenAnswer((_) => Future.value(true));

      final state = AppState.initialState().copyWith(auth: AuthState.initialState().copyWith(user: user));
      final store = Store<AppState>(
        appReducer,
        initialState: state,
        middleware: [EpicMiddleware(onTokenRefreshEpic(firestore: firestore, serverTimestamp: timestamp, firebaseMessaging: firebaseMessagingMock))],
      );

      store.dispatch(FCMTokenRefreshed(token: "TEST_TOKEN"));

      await untilCalled(ref.updateData(data));

    });

    test('if user is not yet logged in but already created the fcm token is updated', () async {
      final data = {
        "fcmToken": "TEST_TOKEN",
        "updatedAt":timestamp,
      };

      when(doc.exists).thenReturn(true);
      when(ref.updateData(data)).thenAnswer((_) => Future.value(true));

      final store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
        middleware: [EpicMiddleware(onTokenRefreshEpic(firestore: firestore, serverTimestamp: timestamp, firebaseMessaging: firebaseMessagingMock))],
      );

      store.dispatch(FCMTokenRefreshed(token: "TEST_TOKEN"));
      store.dispatch(LogInCompleted(user: user));

      await untilCalled(ref.updateData(data));
    });

    test('if user is not yet logged in and not already created the user plus fcm token is updated', () async {
      final data = {
        "fcmToken": "TEST_TOKEN",
        "subscription": {"numberPlate": "", "createdAt": timestamp},
        "updatedAt": timestamp,
        "createdAt": timestamp
      };

      when(doc.exists).thenReturn(false);
      when(ref.setData(data)).thenAnswer((_) => Future.value(true));

      final store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
        middleware: [EpicMiddleware(onTokenRefreshEpic(firestore: firestore, serverTimestamp: timestamp, firebaseMessaging: firebaseMessagingMock))],
      );

      store.dispatch(FCMTokenRefreshed(token: "TEST_TOKEN"));
      store.dispatch(LogInCompleted(user: user));

      await untilCalled(ref.setData(data));
    });

    test('if token changes it gets updated', () async {
      final data1 = {
        "fcmToken": "TEST_TOKEN_1",
        "updatedAt":timestamp,
      };

      final data2 = {
        "fcmToken": "TEST_TOKEN_2",
        "updatedAt":timestamp,
      };

      when(doc.exists).thenReturn(true);
      when(ref.updateData(data1)).thenAnswer((_) => Future.value(true));
      when(ref.updateData(data2)).thenAnswer((_) => Future.value(true));

      final state = AppState.initialState().copyWith(auth: AuthState.initialState().copyWith(user: user));
      final store = Store<AppState>(
        appReducer,
        initialState: state,
        middleware: [EpicMiddleware(onTokenRefreshEpic(firestore: firestore, serverTimestamp: timestamp, firebaseMessaging: firebaseMessagingMock))],
      );

      store.dispatch(FCMTokenRefreshed(token: data1["fcmToken"]));
      await untilCalled(ref.updateData(data1));

      store.dispatch(FCMTokenRefreshed(token: data2["fcmToken"]));
      await untilCalled(ref.updateData(data2));

    });

    test('if user logs out no attempt of updating the token is made', () async {
      final ref = DocumentReferenceMock();
      final doc = DocumentSnapshotMock();
      final userId = "test uid";
      final timestamp = FieldValue.serverTimestamp();

      when(firestore.document("/users/$userId")).thenReturn(ref);
      when(ref.get()).thenAnswer((_) => Future.value(doc));

      final data = {
        "fcmToken": "TEST_TOKEN_1",
        "updatedAt":timestamp,
      };


      when(doc.exists).thenReturn(true);
      when(ref.updateData(data)).thenAnswer((_) => Future.value(true));

      final state = AppState.initialState().copyWith(auth: AuthState.initialState().copyWith(user: user));
      final store = Store<AppState>(
        appReducer,
        initialState: state,
        middleware: [EpicMiddleware(onTokenRefreshEpic(firestore: firestore, serverTimestamp: timestamp, firebaseMessaging: firebaseMessagingMock))],
      );

      store.dispatch(LogOutCompleted());
      store.dispatch(FCMTokenRefreshed(token: data["fcmToken"]));
      store.dispatch(FCMTokenRefreshed(token: data["fcmToken"]));
      store.dispatch(FCMTokenRefreshed(token: data["fcmToken"]));
      await Future.delayed(Duration(milliseconds: 50));
      verifyZeroInteractions(ref);
    });

  });
}

