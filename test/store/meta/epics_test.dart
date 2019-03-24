import 'dart:async';

import 'package:lenden/store/auth/actions.dart';
import 'package:lenden/store/meta/state.dart';
import 'package:lenden/store/prefs/actions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lenden/store/meta/actions.dart';
import 'package:lenden/store/meta/epics.dart';
import 'package:redux/redux.dart';
import 'package:lenden/store/state.dart';
import 'package:lenden/store/reducers.dart';
import 'package:redux_epics/redux_epics.dart';


class FirebaseUserMock extends Mock implements FirebaseUser {}
class FirestoreMock extends Mock implements Firestore {}


main() {
  wait(int milliseconds) {
    return Future.delayed(Duration(milliseconds: milliseconds), null);
  }

  final firestoreMock = FirestoreMock();
  when(firestoreMock.settings(timestampsInSnapshotsEnabled: true)).thenAnswer((_) => Future.value(true));

  group('meta epic', () {
    test('should complete initialisation after log in and preferences are loaded 1', () async {

      final store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
        middleware: [EpicMiddleware(observeInitStateEpic(firestore: firestoreMock))],
      );

      store.dispatch(StartObservingInitState());
      store.dispatch(LogInCompleted(user: FirebaseUserMock()));
      store.dispatch(LoadPreferencesCompleted());

      await wait(200);

      expect(store.state.meta.initState, InitState.Loaded);

    });

    test('should complete initialisation after log in and preferences are loaded 2', () async {

      final store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
        middleware: [EpicMiddleware(observeInitStateEpic(firestore: firestoreMock))],
      );

      store.dispatch(LogInCompleted(user: FirebaseUserMock()));
      store.dispatch(StartObservingInitState());
      store.dispatch(LoadPreferencesCompleted());

      await wait(200);

      expect(store.state.meta.initState, InitState.Loaded);

    });

    test('should complete initialisation after log in and preferences are loaded 3', () async {

      final store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
        middleware: [EpicMiddleware(observeInitStateEpic(firestore: firestoreMock))],
      );

      store.dispatch(LoadPreferencesCompleted());
      store.dispatch(StartObservingInitState());
      store.dispatch(LogInCompleted(user: FirebaseUserMock()));

      await wait(200);

      expect(store.state.meta.initState, InitState.Loaded);

    });

    test('should complete initialisation after log in and preferences are loaded 4', () async {

      final store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
        middleware: [EpicMiddleware(observeInitStateEpic(firestore: firestoreMock))],
      );

      store.dispatch(LoadPreferencesCompleted());
      store.dispatch(LogInCompleted(user: FirebaseUserMock()));

      store.dispatch(StartObservingInitState());

      await wait(200);

      expect(store.state.meta.initState, InitState.Loaded);

    });
  });
}
