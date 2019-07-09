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

  Map<String, dynamic> toJson() => {
    "initState": this.initState.toString(),
    "plopFilePath": this.plopFilePath,
    "audioPlayer": this.audioPlayer.toString(),
  };

  factory MetaState.fromJson(Map<String, dynamic> json) =>
      MetaState.initialState();
}
