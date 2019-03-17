import 'package:firebase_auth/firebase_auth.dart';

class StartObservingAuthState {}

class StopObservingAuthState {}

class AuthStateChanged {
  final FirebaseUser user;
  final dynamic error;
  AuthStateChanged({this.user, this.error});
}

class LogIn {}

class LogInCompleted {
  final FirebaseUser user;
  final dynamic error;
  LogInCompleted({this.user, this.error});
}

class LogOut {}

class LogOutCompleted {
  final dynamic error;
  LogOutCompleted({this.error});
}
