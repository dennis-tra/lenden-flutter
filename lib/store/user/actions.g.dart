// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDataChanged _$UserDataChangedFromJson(Map<String, dynamic> json) {
  return UserDataChanged(
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      error: json['error']);
}

Map<String, dynamic> _$UserDataChangedToJson(UserDataChanged instance) =>
    <String, dynamic>{'user': instance.user, 'error': instance.error};

FCMTokenRefreshed _$FCMTokenRefreshedFromJson(Map<String, dynamic> json) {
  return FCMTokenRefreshed(
      token: json['token'] as String, error: json['error']);
}

Map<String, dynamic> _$FCMTokenRefreshedToJson(FCMTokenRefreshed instance) =>
    <String, dynamic>{'token': instance.token, 'error': instance.error};
