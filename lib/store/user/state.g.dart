// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserState _$UserStateFromJson(Map<String, dynamic> json) {
  return UserState(
      status: _$enumDecodeNullable(_$StatusEnumMap, json['status']),
      fcmStatus: _$enumDecodeNullable(_$StatusEnumMap, json['fcmStatus']),
      error: json['error'],
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>));
}

Map<String, dynamic> _$UserStateToJson(UserState instance) => <String, dynamic>{
      'status': _$StatusEnumMap[instance.status],
      'fcmStatus': _$StatusEnumMap[instance.fcmStatus],
      'error': instance.error,
      'user': instance.user
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$StatusEnumMap = <Status, dynamic>{
  Status.Idle: 'Idle',
  Status.Watching: 'Watching'
};
