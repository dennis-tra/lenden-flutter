import 'package:audioplayers/audioplayers.dart';

enum InitState { Unknown, Loading, Loaded }

class MetaState {
  final InitState initState;
  final AudioPlayer audioPlayer;
  final String plopFilePath;

  MetaState(
      {this.initState = InitState.Unknown,
      this.audioPlayer,
      this.plopFilePath});

  MetaState copyWith(
      {InitState initState, AudioPlayer audioPlayer, String plopFilePath}) {
    return MetaState(
        initState: initState ?? this.initState,
        audioPlayer: audioPlayer ?? this.audioPlayer,
        plopFilePath: plopFilePath ?? this.plopFilePath);
  }

  static MetaState initialState() {
    return MetaState();
  }

  @override
  String toString() {
    return "MetaState{initState: $initState, audioPlayer: $audioPlayer, plopFilePath: $plopFilePath}";
  }
}
