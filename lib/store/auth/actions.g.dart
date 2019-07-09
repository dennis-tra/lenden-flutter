// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthStateChanged _$AuthStateChangedFromJson(Map<String, dynamic> json) {
  return AuthStateChanged(
      user: firebaseUserFromJson(json['user'] as Map<String, dynamic>),
      error: json['error']);
}

Map<String, dynamic> _$AuthStateChangedToJson(AuthStateChanged instance) =>
    <String, dynamic>{
      'user': firebaseUserToJson(instance.user),
      'error': instance.error
    };

LogInCompleted _$LogInCompletedFromJson(Map<String, dynamic> json) {
  return LogInCompleted(
      user: firebaseUserFromJson(json['user'] as Map<String, dynamic>),
      error: json['error']);
}

Map<String, dynamic> _$LogInCompletedToJson(LogInCompleted instance) =>
    <String, dynamic>{
      'user': firebaseUserToJson(instance.user),
      'error': instance.error
    };

LogOutCompleted _$LogOutCompletedFromJson(Map<String, dynamic> json) {
  return LogOutCompleted(error: json['error']);
}

Map<String, dynamic> _$LogOutCompletedToJson(LogOutCompleted instance) =>
    <String, dynamic>{'error': instance.error};
