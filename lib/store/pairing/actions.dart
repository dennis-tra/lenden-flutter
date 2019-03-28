import 'package:lenden/models/pairing.dart';

class StartObservingPairingState {}

class PairingStateChanged {
  final Pairing pairing;
  final dynamic error;
  PairingStateChanged({this.pairing, this.error});
}

class StopObservingPairingState {}

class Pair {
  final String uid;
  Pair({this.uid});
}

class PairCompleted {
  final dynamic error;
  PairCompleted({this.error});
}

class Unpair {}

class UnpairCompleted {
  final dynamic error;
  UnpairCompleted({this.error});
}
