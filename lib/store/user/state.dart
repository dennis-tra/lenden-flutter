import 'package:lenden/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'state.g.dart';

enum Status { Idle, Watching }

@JsonSerializable()
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

  Map<String, dynamic> toJson() => _$UserStateToJson(this);
}
