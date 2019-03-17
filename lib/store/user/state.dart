import 'package:lenden/models/user.dart';

enum Status { Idle, Watching }

class UserState {
  final Status status;
  final Status fcmStatus;
  final dynamic error;
  final User user;

  UserState(
      {this.status = Status.Idle,
      this.fcmStatus = Status.Idle,
      this.error,
      this.user});

  UserState copyWith(
      {Status fcmStatus, Status status, dynamic error, User user}) {
    return UserState(
      user: user ?? this.user,
      fcmStatus: fcmStatus ?? this.fcmStatus,
      status: status ?? this.status,
      error: error,
    );
  }

  static UserState initialState() {
    return UserState();
  }

  @override
  String toString() {
    return "UserState{user: $user, status: $status, fcmStatus: $fcmStatus, error: $error}";
  }
}
