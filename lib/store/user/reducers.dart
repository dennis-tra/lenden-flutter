import 'package:lenden/store/user/actions.dart';
import 'package:lenden/store/user/state.dart';
import 'package:redux/redux.dart';

final userReducers = combineReducers<UserState>([
  TypedReducer<UserState, UserDataChanged>(_userDataChanged),
  TypedReducer<UserState, StartObservingUserData>(_startObservingUserState),
  TypedReducer<UserState, StopObservingUserData>(_cancelObservingUserState),
  TypedReducer<UserState, StartObservingFCMTokenRefresh>(
      _startObservingFCMTokenRefresh),
  TypedReducer<UserState, StopObservingFCMTokenRefresh>(
      _stopObservingFCMTokenRefresh),
]);

UserState _userDataChanged(UserState userState, UserDataChanged action) {
  return UserState(
      user: action.user, error: action.error, status: userState.status);
}

UserState _startObservingUserState(
    UserState userData, StartObservingUserData action) {
  return userData.copyWith(status: Status.Watching);
}

UserState _cancelObservingUserState(
    UserState userData, StopObservingUserData action) {
  if (userData.status == Status.Watching) {
    return userData.copyWith(status: Status.Idle);
  }
  return userData;
}

UserState _startObservingFCMTokenRefresh(
    UserState userData, StartObservingFCMTokenRefresh action) {
  return userData.copyWith(fcmStatus: Status.Watching);
}

UserState _stopObservingFCMTokenRefresh(
    UserState userData, StopObservingFCMTokenRefresh action) {
  return userData.copyWith(fcmStatus: Status.Idle);
}
