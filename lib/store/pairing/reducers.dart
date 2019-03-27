import 'package:lenden/store/pairing/actions.dart';
import 'package:lenden/store/pairing/state.dart';
import 'package:redux/redux.dart';

final pairingReducers = combineReducers<PairingState>([
  TypedReducer<PairingState, PairingStateChanged>(_pairingStateChanged),
  TypedReducer<PairingState, StartObservingPairingState>(
      _startObservingPairingState),
  TypedReducer<PairingState, StopObservingPairingState>(
      _stopObservingPairingState),
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
