import 'package:firebase_auth/firebase_auth.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lenden/utils/json_serializers.dart';

part 'state.g.dart';

enum Status { LoggedIn, LoggedOut, Unknown }
enum Process {
  // the user is in the process of logging in
  LoggingIn,
  // the user is in the process of logging out
  LoggingOut,
  // the users authentication state is unknown and we need to find out the state
  Orienting,
  // the users state is settled usually on LoggedIn or LoggedOut and we are not attempting to do anything at the moment
  Settled
}

@JsonSerializable()
class AuthState {
  @JsonKey(toJson: firebaseUserToJson, fromJson: firebaseUserFromJson)
  final FirebaseUser user;
  final Status status;
  final Process process;
  final dynamic error;

  AuthState(
      {this.user,
      this.status = Status.Unknown,
      this.process = Process.Settled,
      this.error});

  AuthState copyWith(
      {FirebaseUser user, Status status, Process process, dynamic error}) {
    return AuthState(
      user: user ?? this.user,
      status: status ?? this.status,
      process: process ?? this.process,
      error: error,
    );
  }

  static AuthState initialState() {
    return AuthState();
  }

  Map<String, dynamic> toJson() => _$AuthStateToJson(this);
}
