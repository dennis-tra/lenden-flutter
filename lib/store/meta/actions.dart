import 'package:audioplayers/audioplayers.dart';

class StartObservingInitState {}

class InitCompleted {}

class StopObservingInitState {}

class InitAudioplayer {}

class InitAudioplayerCompleted {
  AudioPlayer audioPlayer;
  String plopFile;
  Error error;
  InitAudioplayerCompleted({this.audioPlayer, this.plopFile, this.error});

  Map<String, dynamic> toJson() => {
        "error": this.error,
        "plopFile": this.plopFile,
      };
}

class PlayPlopSound {}
