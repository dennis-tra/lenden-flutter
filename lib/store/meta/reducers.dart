import 'package:lenden/store/meta/actions.dart';
import 'package:lenden/store/meta/state.dart';
import 'package:redux/redux.dart';

final metaReducers = combineReducers<MetaState>([
  TypedReducer<MetaState, InitCompleted>(_userDataChanged),
  TypedReducer<MetaState, StartObservingInitState>(_startObservingInitState),
  TypedReducer<MetaState, StopObservingInitState>(_stopObservingInitState),
  TypedReducer<MetaState, InitAudioplayerCompleted>(_initAudioplayerCompleted),
]);

MetaState _userDataChanged(MetaState metaState, InitCompleted action) {
  return metaState.copyWith(initState: InitState.Loaded);
}

MetaState _startObservingInitState(
    MetaState metaState, StartObservingInitState action) {
  return metaState.copyWith(initState: InitState.Loading);
}

MetaState _stopObservingInitState(
    MetaState metaState, StopObservingInitState action) {
  return metaState;
}

MetaState _initAudioplayerCompleted(
    MetaState metaState, InitAudioplayerCompleted action) {
  return metaState.copyWith(
      audioPlayer: action.audioPlayer, plopFilePath: action.plopFile);
}
