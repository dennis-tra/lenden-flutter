// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoadPreferencesCompleted _$LoadPreferencesCompletedFromJson(
    Map<String, dynamic> json) {
  return LoadPreferencesCompleted(
      launchCount: json['launchCount'] as int, error: json['error']);
}

Map<String, dynamic> _$LoadPreferencesCompletedToJson(
        LoadPreferencesCompleted instance) =>
    <String, dynamic>{
      'launchCount': instance.launchCount,
      'error': instance.error
    };
