import 'package:lenden/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'actions.g.dart';

class StartObservingUserData {}

class StopObservingUserData {}

@JsonSerializable()
class UserDataChanged {
  final User user;
  final dynamic error;
  UserDataChanged({this.user, this.error});

  Map<String, dynamic> toJson() => _$UserDataChangedToJson(this);
}

class StartObservingFCMTokenRefresh {}

class StopObservingFCMTokenRefresh {}

@JsonSerializable()
class FCMTokenRefreshed {
  final String token;
  final dynamic error;

  FCMTokenRefreshed({this.token, this.error});

  bool operator ==(other) {
    if (other is FCMTokenRefreshed) {
      return other.token == token && other.error == error;
    }
    return false;
  }

  int get hashCode => token.hashCode ^ error.hashCode;

  Map<String, dynamic> toJson() => _$FCMTokenRefreshedToJson(this);
}
