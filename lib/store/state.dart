import 'package:lenden/store/auth/state.dart';
import 'package:lenden/store/meta/state.dart';
import 'package:lenden/store/prefs/state.dart';
import 'package:lenden/store/user/state.dart';

class AppState {
  final AuthState auth;
  final UserState user;
  final PrefsState prefs;
  final MetaState meta;

  AppState({this.auth, this.prefs, this.user, this.meta});

  static AppState initialState() {
    return AppState(
        auth: AuthState.initialState(),
        prefs: PrefsState.initialState(),
        user: UserState.initialState(),
        meta: MetaState.initialState());
  }

  AppState copyWith(
      {AuthState auth, PrefsState prefs, UserState user, MetaState meta}) {
    return AppState(
      auth: auth ?? this.auth,
      prefs: prefs ?? this.prefs,
      user: user ?? this.user,
      meta: meta ?? this.meta,
    );
  }

  @override
  String toString() {
    return "AppState{auth: $auth, user: $user, prefs: $prefs, meta: $meta}";
  }
}
