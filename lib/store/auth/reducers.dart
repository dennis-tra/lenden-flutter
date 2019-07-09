import 'package:redux/redux.dart';
import 'package:lenden/store/auth/actions.dart';
import 'package:lenden/store/auth/state.dart';

final authReducers = combineReducers<AuthState>([
  TypedReducer<AuthState, AuthStateChanged>(_authStateChanged),
  TypedReducer<AuthState, StartObservingAuthState>(_startObservingAuthState),
  TypedReducer<AuthState, StopObservingAuthState>(_cancelObservingAuthState),
  TypedReducer<AuthState, LogIn>(_logIn),
  TypedReducer<AuthState, LogInCompleted>(_logInCompleted),
  TypedReducer<AuthState, LogOut>(_logOut),
  TypedReducer<AuthState, LogOutCompleted>(_logOutCompleted),
]);

AuthState _authStateChanged(AuthState authState, AuthStateChanged action) {
  return AuthState(
      user: action.user,
      status: action.user == null ? Status.LoggedOut : Status.LoggedIn,
      process: authState.process == Process.Orienting
          ? Process.Settled
          : authState.process,
      error: action.error);
}

AuthState _startObservingAuthState(
    AuthState authState, StartObservingAuthState action) {
  return authState.copyWith(process: Process.Orienting);
}

AuthState _cancelObservingAuthState(
    AuthState authState, StopObservingAuthState action) {
  if (authState.process == Process.Orienting) {
    return authState.copyWith(process: Process.Settled);
  }
  return authState;
}

AuthState _logIn(AuthState authState, LogIn action) {
  return authState.copyWith(process: Process.LoggingIn);
}

AuthState _logInCompleted(AuthState authState, LogInCompleted action) {
  if (action.error != null) {
    return authState.copyWith(error: action.error, process: Process.Settled);
  }
  return authState.copyWith(
      user: action.user, status: Status.LoggedIn, process: Process.Settled);
}

AuthState _logOut(AuthState authState, LogOut action) {
  return authState.copyWith(process: Process.LoggingOut);
}

AuthState _logOutCompleted(AuthState authState, LogOutCompleted action) {
  if (action.error != null) {
    return authState.copyWith(error: action.error, process: Process.Settled);
  }
  return AuthState(status: Status.LoggedOut, process: Process.Settled);
}
