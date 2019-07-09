// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthState _$AuthStateFromJson(Map<String, dynamic> json) {
  return AuthState(
      user: firebaseUserFromJson(json['user'] as Map<String, dynamic>),
      status: _$enumDecodeNullable(_$StatusEnumMap, json['status']),
      process: _$enumDecodeNullable(_$ProcessEnumMap, json['process']),
      error: json['error']);
}

Map<String, dynamic> _$AuthStateToJson(AuthState instance) => <String, dynamic>{
      'user': firebaseUserToJson(instance.user),
      'status': _$StatusEnumMap[instance.status],
      'process': _$ProcessEnumMap[instance.process],
      'error': instance.error
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
  Status.LoggedIn: 'LoggedIn',
  Status.LoggedOut: 'LoggedOut',
  Status.Unknown: 'Unknown'
};

const _$ProcessEnumMap = <Process, dynamic>{
  Process.LoggingIn: 'LoggingIn',
  Process.LoggingOut: 'LoggingOut',
  Process.Orienting: 'Orienting',
  Process.Settled: 'Settled'
};
