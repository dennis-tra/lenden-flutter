// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingState _$PairingStateFromJson(Map<String, dynamic> json) {
  return PairingState(
      status: _$enumDecodeNullable(_$StatusEnumMap, json['status']),
      process: _$enumDecodeNullable(_$ProcessEnumMap, json['process']),
      pairing: json['pairing'] == null
          ? null
          : Pairing.fromJson(json['pairing'] as Map<String, dynamic>),
      error: json['error']);
}

Map<String, dynamic> _$PairingStateToJson(PairingState instance) =>
    <String, dynamic>{
      'status': _$StatusEnumMap[instance.status],
      'process': _$ProcessEnumMap[instance.process],
      'error': instance.error,
      'pairing': instance.pairing
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

const _$ProcessEnumMap = <Process, dynamic>{
  Process.Pairing: 'Pairing',
  Process.Unpairing: 'Unpairing',
  Process.Orienting: 'Orienting',
  Process.Settled: 'Settled'
};
