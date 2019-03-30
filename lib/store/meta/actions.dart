import 'package:audioplayers/audioplayers.dart';

class StartObservingInitState {}

class InitCompleted {}

class StopObservingInitState {}

class InitAudioplayer {}

class InitAudioplayerCompleted {
  AudioPlayer audioPlayer;
  String plopFile;
  InitAudioplayerCompleted({this.audioPlayer, this.plopFile});
}

class PlayPlopSound {}
