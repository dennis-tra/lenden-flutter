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
    PairingState metaState, PairingStateChanged action) {
  return metaState.copyWith(pairing: action.pairing, error: action.error);
}

PairingState _startObservingPairingState(
    PairingState metaState, StartObservingPairingState action) {
  return metaState.copyWith(status: Status.Watching);
}

PairingState _stopObservingPairingState(
    PairingState metaState, StopObservingPairingState action) {
  return metaState.copyWith(status: Status.Idle);
}
