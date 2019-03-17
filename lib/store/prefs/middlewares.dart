import 'package:lenden/store/prefs/actions.dart';
import 'package:lenden/store/prefs/state.dart';
import 'package:lenden/store/state.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

const PREFERENCES_KEY_LAUNCH_COUNT = "launchCount";

List<Middleware<AppState>> createPrefsMiddleware(
    {Future<SharedPreferences> sharedPreferences}) {
  sharedPreferences = sharedPreferences ?? SharedPreferences.getInstance();

  return [
    TypedMiddleware<AppState, LoadPreferences>(
        _loadPreferences(sharedPreferences)),
  ];
}

_loadPreferences(Future<SharedPreferences> sharedPreferences) {
  return (Store<AppState> store, LoadPreferences action, NextDispatcher next) {
    var status = store.state.prefs.status;

    if (status != Status.Loading) {
      sharedPreferences.then((prefs) {
        var launchCount = prefs.getInt(PREFERENCES_KEY_LAUNCH_COUNT) ?? 0;
        prefs.setInt(PREFERENCES_KEY_LAUNCH_COUNT, launchCount + 1);

        store.dispatch(
            LoadPreferencesCompleted(launchCount: launchCount, error: null));
      }).catchError((err) {
        store.dispatch(LoadPreferencesCompleted(launchCount: null, error: err));
      });
    }

    next(action);
  };
}
