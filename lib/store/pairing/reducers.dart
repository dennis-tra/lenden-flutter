import 'package:lenden/store/pairing/actions.dart';
import 'package:lenden/store/pairing/state.dart';
import 'package:redux/redux.dart';

final pairingReducers = combineReducers<PairingState>([
  TypedReducer<PairingState, PairingStateChanged>(_pairingStateChanged),
  TypedReducer<PairingState, StartObservingPairingState>(
      _startObservingPairingState),
  TypedReducer<PairingState, StopObservingPairingState>(
      _stopObservingPairingState),
  TypedReducer<PairingState, Pair>(_pair),
  TypedReducer<PairingState, PairCompleted>(_pairCompleted),
  TypedReducer<PairingState, Unpair>(_unpair),
  TypedReducer<PairingState, UnpairCompleted>(_unpairCompleted),
]);

PairingState _pairingStateChanged(
    PairingState pairingState, PairingStateChanged action) {
  return PairingState(
      pairing: action.pairing,
      error: action.error,
      status: pairingState.status);
}

PairingState _startObservingPairingState(
    PairingState pairingState, StartObservingPairingState action) {
  return pairingState.copyWith(status: Status.Watching);
}

PairingState _stopObservingPairingState(
    PairingState pairingState, StopObservingPairingState action) {
  return pairingState.copyWith(status: Status.Idle);
}

PairingState _pair(PairingState pairingState, Pair action) {
  return pairingState.copyWith(process: Process.Pairing);
}

PairingState _pairCompleted(PairingState pairingState, PairCompleted action) {
  return PairingState(
      pairing: pairingState.pairing,
      error: action.error,
      status: pairingState.status,
      process: Process.Settled);
}

PairingState _unpair(PairingState pairingState, Unpair action) {
  return pairingState.copyWith(process: Process.Unpairing);
}

PairingState _unpairCompleted(
    PairingState pairingState, UnpairCompleted action) {
  return PairingState(
      pairing: null,
      error: action.error,
      status: pairingState.status,
      process: Process.Settled);
}
