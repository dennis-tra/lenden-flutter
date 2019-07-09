import 'package:firebase_auth/firebase_auth.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lenden/utils/json_serializers.dart';

part 'actions.g.dart';

class StartObservingAuthState {}

class StopObservingAuthState {}

@JsonSerializable()
class AuthStateChanged {
  @JsonKey(toJson: firebaseUserToJson, fromJson: firebaseUserFromJson)
  final FirebaseUser user;
  final dynamic error;

  AuthStateChanged({this.user, this.error});

  Map<String, dynamic> toJson() => _$AuthStateChangedToJson(this);
}

class LogIn {}

@JsonSerializable()
class LogInCompleted {
  @JsonKey(toJson: firebaseUserToJson, fromJson: firebaseUserFromJson)
  final FirebaseUser user;
  final dynamic error;

  LogInCompleted({this.user, this.error});

  Map<String, dynamic> toJson() => _$LogInCompletedToJson(this);
}

class LogOut {}

@JsonSerializable()
class LogOutCompleted {
  final dynamic error;

  LogOutCompleted({this.error});

  Map<String, dynamic> toJson() => _$LogOutCompletedToJson(this);
}
