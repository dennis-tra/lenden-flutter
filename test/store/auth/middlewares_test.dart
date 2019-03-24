import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:lenden/store/state.dart';
import 'package:lenden/store/reducers.dart';
import 'package:lenden/store/auth/middlewares.dart';
import 'package:lenden/store/auth/actions.dart';
import 'package:lenden/store/auth/state.dart';

class FirebaseAuthMock extends Mock implements FirebaseAuth {}
class FirebaseUserMock extends Mock implements FirebaseUser {}

main() {
  group('Log in middleware', () {
    test('should log in in response to a LogIn action', () async {

      final firebaseAuth = FirebaseAuthMock();
      final user = FirebaseUserMock();

      final store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
        middleware: createAuthMiddleware(firebaseAuth: firebaseAuth),
      );

      when(firebaseAuth.signInAnonymously()).thenAnswer((_) => Future.value(user));

      store.dispatch(LogIn());

      expect(store.state.auth.user, null);
      expect(store.state.auth.error, null);
      expect(store.state.auth.status, Status.Unknown);
      expect(store.state.auth.process, Process.LoggingIn);

      await untilCalled(firebaseAuth.signInAnonymously());

    });

    test('should call sign in only once on multiple LogIn actions', () async {

      final firebaseAuth = FirebaseAuthMock();
      final user = FirebaseUserMock();

      final store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
        middleware: createAuthMiddleware(firebaseAuth: firebaseAuth),
      );

      when(firebaseAuth.signInAnonymously()).thenAnswer((_) => Future.value(user));

      store.dispatch(LogIn());
      store.dispatch(LogIn());
      store.dispatch(LogIn());

      verify(firebaseAuth.signInAnonymously()).called(1);
    });
  });

  group('Log out middleware', () {

  });
}