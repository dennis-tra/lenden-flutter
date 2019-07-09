// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrefsState _$PrefsStateFromJson(Map<String, dynamic> json) {
  return PrefsState(
      launchCount: json['launchCount'] as int,
      status: _$enumDecodeNullable(_$StatusEnumMap, json['status']),
      error: json['error']);
}

Map<String, dynamic> _$PrefsStateToJson(PrefsState instance) =>
    <String, dynamic>{
      'launchCount': instance.launchCount,
      'status': _$StatusEnumMap[instance.status],
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
  Status.Unknown: 'Unknown',
  Status.Loading: 'Loading',
  Status.Loaded: 'Loaded',
  Status.Failed: 'Failed'
};
