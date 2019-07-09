import 'package:json_annotation/json_annotation.dart';

part 'state.g.dart';

enum Status { Unknown, Loading, Loaded, Failed }

@JsonSerializable()
class PrefsState {
  final int launchCount;
  final Status status;
  final dynamic error;

  PrefsState({this.launchCount, this.status = Status.Unknown, this.error});

  PrefsState copyWith({int launchCount, Status status, dynamic error}) {
    return PrefsState(
      launchCount: launchCount,
      status: status,
      error: error,
    );
  }

  static PrefsState initialState() {
    return PrefsState();
  }

  Map<String, dynamic> toJson() => _$PrefsStateToJson(this);
}
