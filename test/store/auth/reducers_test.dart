import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:lenden/store/state.dart';
import 'package:lenden/store/reducers.dart';
import 'package:lenden/store/auth/actions.dart';
import 'package:lenden/store/auth/state.dart';


class FirebaseUserMock extends Mock implements FirebaseUser {}

main() {
  group("AuthState Reducer from initial state", () {

    test("initial state", () {
      final store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
      );

      expect(store.state.auth.status, Status.Unknown);
      expect(store.state.auth.process, Process.Settled);
      expect(store.state.auth.user, null);
      expect(store.state.auth.error, null);
    });

    test("Set correct values when logging in from initial state", () {
      final store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
      );

      store.dispatch(LogIn());

      expect(store.state.auth.status, Status.Unknown);
      expect(store.state.auth.process, Process.LoggingIn);
      expect(store.state.auth.user, null);
      expect(store.state.auth.error, null);
    });

    test("Set correct values when logging out from initial state", () {
      final store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
      );

      store.dispatch(LogOut());

      expect(store.state.auth.status, Status.Unknown);
      expect(store.state.auth.process, Process.LoggingOut);
      expect(store.state.auth.user, null);
      expect(store.state.auth.error, null);
    });
  });

  group("AuthState Reducer from logged in user", () {

    test("has correct values for logged in user", () {
      final store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
      );

      final user = FirebaseUserMock();

      store.dispatch(LogIn());
      store.dispatch(LogInCompleted(user: user, error: null));

      expect(store.state.auth.status, Status.LoggedIn);
      expect(store.state.auth.process, Process.Settled);
      expect(store.state.auth.user, user);
      expect(store.state.auth.error, null);
    });

    test("handles another log in gracefully", () {
      final store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
      );

      final user = FirebaseUserMock();

      store.dispatch(LogIn());
      store.dispatch(LogInCompleted(user: user, error: null));

      store.dispatch(LogIn());

      expect(store.state.auth.status, Status.LoggedIn);
      expect(store.state.auth.process, Process.LoggingIn);
      expect(store.state.auth.user, user);
      expect(store.state.auth.error, null);
    });
  });
}
