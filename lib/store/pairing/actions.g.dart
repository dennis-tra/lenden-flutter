// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingStateChanged _$PairingStateChangedFromJson(Map<String, dynamic> json) {
  return PairingStateChanged(
      pairing: json['pairing'] == null
          ? null
          : Pairing.fromJson(json['pairing'] as Map<String, dynamic>),
      error: json['error']);
}

Map<String, dynamic> _$PairingStateChangedToJson(
        PairingStateChanged instance) =>
    <String, dynamic>{'pairing': instance.pairing, 'error': instance.error};

Pair _$PairFromJson(Map<String, dynamic> json) {
  return Pair(uid: json['uid'] as String);
}

Map<String, dynamic> _$PairToJson(Pair instance) =>
    <String, dynamic>{'uid': instance.uid};

PairCompleted _$PairCompletedFromJson(Map<String, dynamic> json) {
  return PairCompleted(error: json['error']);
}

Map<String, dynamic> _$PairCompletedToJson(PairCompleted instance) =>
    <String, dynamic>{'error': instance.error};

UnpairCompleted _$UnpairCompletedFromJson(Map<String, dynamic> json) {
  return UnpairCompleted(error: json['error']);
}

Map<String, dynamic> _$UnpairCompletedToJson(UnpairCompleted instance) =>
    <String, dynamic>{'error': instance.error};
