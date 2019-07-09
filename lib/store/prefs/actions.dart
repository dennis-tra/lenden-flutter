import 'package:json_annotation/json_annotation.dart';

part 'actions.g.dart';

class LoadPreferences {}

@JsonSerializable()
class LoadPreferencesCompleted {
  final int launchCount;
  final dynamic error;

  LoadPreferencesCompleted({this.launchCount, this.error});

  Map<String, dynamic> toJson() => _$LoadPreferencesCompletedToJson(this);
}
