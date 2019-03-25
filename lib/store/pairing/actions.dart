import 'package:lenden/models/pairing.dart';

class StartObservingPairingState {}

class PairingStateChanged {
  final Pairing pairing;
  final dynamic error;
  PairingStateChanged({this.pairing, this.error});
}

class StopObservingPairingState {}
