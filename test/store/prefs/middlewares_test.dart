import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:lenden/store/state.dart';
import 'package:lenden/store/reducers.dart';
import 'package:lenden/store/prefs/middlewares.dart';
import 'package:lenden/store/prefs/actions.dart';
import 'package:lenden/store/prefs/state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesMock extends Mock implements SharedPreferences {}

main() {
  group('load preferences middleware', () {
    test('should log in in response to a LogIn action', () async {
      final sharedPreferences = SharedPreferencesMock();
      final sharedPreferencesFuture = Future.value(sharedPreferences);

      final store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
        middleware: createPrefsMiddleware(sharedPreferences: sharedPreferencesFuture),
      );

      final launchCount = 2;

      when(sharedPreferences.getInt(PREFERENCES_KEY_LAUNCH_COUNT)).thenReturn(launchCount);

      store.dispatch(LoadPreferences());

      await untilCalled(sharedPreferences.getInt(PREFERENCES_KEY_LAUNCH_COUNT));

      verify(sharedPreferences.setInt(PREFERENCES_KEY_LAUNCH_COUNT, launchCount + 1));

      expect(store.state.prefs.launchCount, launchCount);
      expect(store.state.prefs.status, Status.Loaded);
      expect(store.state.prefs.error, null);
    });
  });
}
