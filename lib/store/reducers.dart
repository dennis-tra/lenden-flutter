import 'package:lenden/store/state.dart';
import 'package:lenden/store/auth/reducers.dart';
import 'package:lenden/store/prefs/reducers.dart';
import 'package:lenden/store/user/reducers.dart';
import 'package:lenden/store/meta/reducers.dart';

AppState appReducer(AppState state, action) {
  return AppState(
    auth: authReducers(state.auth, action),
    prefs: prefsReducers(state.prefs, action),
    user: userReducers(state.user, action),
    meta: metaReducers(state.meta, action),
  );
}
