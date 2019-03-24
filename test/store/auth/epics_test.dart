import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lenden/store/auth/actions.dart';
import 'package:lenden/store/auth/epics.dart';
import 'package:redux/redux.dart';
import 'package:lenden/store/state.dart';
import 'package:lenden/store/reducers.dart';
import 'package:redux_epics/redux_epics.dart';

class FirebaseAuthMock extends Mock implements FirebaseAuth {}
class FirebaseUserMock extends Mock implements FirebaseUser {}

main() {
  wait(int milliseconds) {
    return Future.delayed(Duration(milliseconds: milliseconds), null);
  }

  group('Log in middleware', () {
    test('should log in in response to a LogIn action', () async {
      final firebaseAuth = FirebaseAuthMock();
      final firebaseUser = FirebaseUserMock();

      final store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
        middleware: [EpicMiddleware(observeAuthStateEpic(firebaseAuth: firebaseAuth))],
      );

      when(firebaseAuth.onAuthStateChanged).thenAnswer((_) => Stream.fromIterable([firebaseUser]));

      store.dispatch(StartObservingAuthState());

      await wait(200);

      expect(store.state.auth.user, firebaseUser);

    });
  });
}
