import 'package:lenden/models/user.dart';

class StartObservingUserData {}

class StopObservingUserData {}

class UserDataChanged {
  final User user;
  final dynamic error;
  UserDataChanged({this.user, this.error});

  @override
  String toString() {
    return "UserDataChanged{user: $user, error: $error}";
  }
}

class StartObservingFCMTokenRefresh {}

class StopObservingFCMTokenRefresh {}

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

  @override
  String toString() {
    return "FCMTokenRefreshed{token: $token, error: $error}";
  }
}
