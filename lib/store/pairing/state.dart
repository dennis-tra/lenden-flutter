import 'package:lenden/models/pairing.dart';

enum Status { Idle, Watching }
enum Process {
  // the user has initiated the pairing process
  Pairing,
  // the user has initiated the unpairing process
  Unpairing,
  // the users pairing state is unknown
  Orienting,
  // the users pairing state is settled and we are not attempting to do anything at the moment
  Settled,
}

class PairingState {
  final Status status;
  final Process process;
  final dynamic error;
  final Pairing pairing;

  PairingState(
      {this.status = Status.Idle,
      this.process = Process.Settled,
      this.pairing,
      this.error});

  PairingState copyWith(
      {Status status, Error error, Process process, Pairing pairing}) {
    return PairingState(
      status: status ?? this.status,
      process: process ?? this.process,
      pairing: pairing ?? this.pairing,
      error: error ?? this.error,
    );
  }

  static PairingState initialState() {
    return PairingState();
  }

  @override
  String toString() {
    return "PairingState{status: $status, process: $process, pairing: $pairing, error: $error}";
  }
}
