import 'package:lenden/models/pairing.dart';

enum Status { Idle, Watching }

class PairingState {
  final Status status;
  final dynamic error;
  final Pairing pairing;

  PairingState({this.status = Status.Idle, this.pairing, this.error});

  PairingState copyWith({Status status, Error error, Pairing pairing}) {
    return PairingState(
      status: status ?? this.status,
      pairing: pairing ?? this.pairing,
      error: error ?? this.error,
    );
  }

  static PairingState initialState() {
    return PairingState();
  }

  @override
  String toString() {
    return "PairingState{status: $status, pairing: $pairing, error: $error}";
  }
}
