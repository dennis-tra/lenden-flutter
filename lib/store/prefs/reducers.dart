import 'package:lenden/store/prefs/actions.dart';
import 'package:lenden/store/prefs/state.dart';
import 'package:redux/redux.dart';

final prefsReducers = combineReducers<PrefsState>([
  TypedReducer<PrefsState, LoadPreferences>(_loadPreferences),
  TypedReducer<PrefsState, LoadPreferencesCompleted>(_loadPreferencesCompleted),
]);

PrefsState _loadPreferences(PrefsState prefsState, LoadPreferences action) {
  return prefsState.copyWith(
      error: null, launchCount: prefsState.launchCount, status: Status.Loading);
}

PrefsState _loadPreferencesCompleted(
    PrefsState prefsState, LoadPreferencesCompleted action) {
  if (action.error != null) {
    return prefsState.copyWith(status: Status.Failed, error: action.error);
  }

  return prefsState.copyWith(
      launchCount: action.launchCount, status: Status.Loaded, error: null);
}
