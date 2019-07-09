import 'package:lenden/store/auth/state.dart';
import 'package:lenden/store/meta/state.dart';
import 'package:lenden/store/prefs/state.dart';
import 'package:lenden/store/user/state.dart';
import 'package:lenden/store/pairing/state.dart';
import 'package:json_annotation/json_annotation.dart';

part 'state.g.dart';

@JsonSerializable(explicitToJson: true, createFactory: false)
class AppState {
  final AuthState auth;
  final UserState user;
  final PrefsState prefs;
  final MetaState meta;
  final PairingState pairing;

  AppState({this.auth, this.prefs, this.user, this.meta, this.pairing});

  static AppState initialState() {
    return AppState(
        auth: AuthState.initialState(),
        prefs: PrefsState.initialState(),
        user: UserState.initialState(),
        meta: MetaState.initialState(),
        pairing: PairingState.initialState());
  }

  AppState copyWith(
      {AuthState auth,
      PrefsState prefs,
      UserState user,
      MetaState meta,
      PairingState pairing}) {
    return AppState(
      auth: auth ?? this.auth,
      prefs: prefs ?? this.prefs,
      user: user ?? this.user,
      meta: meta ?? this.meta,
      pairing: pairing ?? this.pairing,
    );
  }

  @override
  String toString() {
    return "AppState{auth: $auth, user: $user, prefs: $prefs, meta: $meta, pairing: $pairing}";
  }

  Map<String, dynamic> toJson() => _$AppStateToJson(this);
}
