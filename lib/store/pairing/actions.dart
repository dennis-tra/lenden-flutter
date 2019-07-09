import 'package:json_annotation/json_annotation.dart';
import 'package:lenden/models/pairing.dart';

part 'actions.g.dart';

class StartObservingPairingState {}

@JsonSerializable()
class PairingStateChanged {
  final Pairing pairing;
  final dynamic error;

  PairingStateChanged({this.pairing, this.error});

  Map<String, dynamic> toJson() => _$PairingStateChangedToJson(this);
}

class StopObservingPairingState {}

@JsonSerializable()
class Pair {
  final String uid;

  Pair({this.uid});

  Map<String, dynamic> toJson() => _$PairToJson(this);
}

@JsonSerializable()
class PairCompleted {
  final dynamic error;

  PairCompleted({this.error});

  Map<String, dynamic> toJson() => _$PairCompletedToJson(this);
}

class Unpair {}

@JsonSerializable()
class UnpairCompleted {
  final dynamic error;

  UnpairCompleted({this.error});

  Map<String, dynamic> toJson() => _$UnpairCompletedToJson(this);
}
