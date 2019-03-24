import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:lenden/store/state.dart';
import 'package:lenden/store/reducers.dart';
import 'package:lenden/store/prefs/actions.dart';
import 'package:lenden/store/prefs/state.dart';


class FirebaseUserMock extends Mock implements FirebaseUser {}

main() {
  group("Preferences Reducer from initial state", () {

    test("initial state", () {
      final store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
      );

      expect(store.state.prefs.launchCount, null);
      expect(store.state.prefs.status, Status.Unknown);
      expect(store.state.prefs.error, null);
    });

    test("Set correct values when loading preferences from initial state", () {
      final store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
      );

      store.dispatch(LoadPreferences());

      expect(store.state.prefs.launchCount, null);
      expect(store.state.prefs.status, Status.Loading);
      expect(store.state.prefs.error, null);
    });
  });

  group("Preferences reducer from already loaded preferences", () {

    test("has correct values for loaded preferences", () {
      final store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
      );

      store.dispatch(LoadPreferences());
      store.dispatch(LoadPreferencesCompleted(launchCount: 2, error: null));

      expect(store.state.prefs.status, Status.Loaded);
      expect(store.state.prefs.launchCount, 2);
      expect(store.state.prefs.error, null);
    });

    test("has correct values for loaded preferences on error", () {
      final store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
      );

      store.dispatch(LoadPreferences());
      store.dispatch(LoadPreferencesCompleted(launchCount: null, error: "ERROR"));

      expect(store.state.prefs.status, Status.Failed);
      expect(store.state.prefs.launchCount, null);
      expect(store.state.prefs.error, "ERROR");
    });

    test("has correct values for loaded preferences on error after preferences already loaded", () {
      final store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
      );

      store.dispatch(LoadPreferences());
      store.dispatch(LoadPreferencesCompleted(launchCount: 2, error: null));
      store.dispatch(LoadPreferencesCompleted(launchCount: null, error: "ERROR"));

      expect(store.state.prefs.status, Status.Failed);
      expect(store.state.prefs.launchCount, null);
      expect(store.state.prefs.error, "ERROR");
    });

  });
}
