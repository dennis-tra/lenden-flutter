// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pairing _$PairingFromJson(Map<String, dynamic> json) {
  return Pairing(
      userIds: (json['userIds'] as List)?.map((e) => e as String)?.toList());
}

Map<String, dynamic> _$PairingToJson(Pairing instance) =>
    <String, dynamic>{'userIds': instance.userIds};
