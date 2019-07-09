import 'dart:io';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:redux/redux.dart';
import 'package:lenden/store/meta/actions.dart';
import 'package:lenden/store/state.dart';
import 'package:lenden/store/pairing/actions.dart';
import 'package:lenden/store/auth/actions.dart';
import 'package:lenden/store/prefs/actions.dart';
import 'package:lenden/store/user/actions.dart';
import 'package:lenden/main.dart';
import 'package:flutter/material.dart';

List<Middleware<AppState>> createMetaMiddleware() {
  return [
    TypedMiddleware<AppState, PlayPlopSound>(_playPlopSoundMiddleware()),
    TypedMiddleware<AppState, InitAudioplayer>(_initAudioplayerMiddleware2()),
    _showToastMiddleware(),
  ];
}

_showToastMiddleware() {
  return (Store<AppState> store, dynamic action, NextDispatcher next) async {
    switch (action.runtimeType) {
      case PairCompleted:
        final payload = action as PairCompleted;
        if (payload.error != null) {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(action.error),
            duration: Duration(seconds: 5),
          ));
        }
        break;
      case UnpairCompleted:
        final payload = action as UnpairCompleted;
        if (payload.error != null) {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(action.error),
            duration: Duration(seconds: 5),
          ));
        }
        break;
      case LogInCompleted:
        final payload = action as LogInCompleted;
        if (payload.error != null) {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(action.error),
            duration: Duration(seconds: 5),
          ));
        }
        break;
      case LoadPreferencesCompleted:
        final payload = action as LoadPreferencesCompleted;
        if (payload.error != null) {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(action.error),
            duration: Duration(seconds: 5),
          ));
        }
        break;
      case FCMTokenRefreshed:
        final payload = action as FCMTokenRefreshed;
        if (payload.error != null) {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(action.error),
            duration: Duration(seconds: 5),
          ));
        }
        break;
      case PairingStateChanged:
        final payload = action as PairingStateChanged;
        if (payload.error != null) {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(action.error),
            duration: Duration(seconds: 5),
          ));
        }
        break;
      default:
    }

    next(action);
  };
}

_initAudioplayerMiddleware() {
  return (Store<AppState> store, InitAudioplayer action,
      NextDispatcher next) async {
    final AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);

    final tmpDir = await getTemporaryDirectory();
    final plopFile = File('${tmpDir.path}/plop.mp3');
    final plopAsset = await rootBundle.load('assets/plop.mp3');

    await plopFile.writeAsBytes(plopAsset.buffer.asUint8List());

    audioPlayer.play(plopFile.path, isLocal: true, volume: 0.0);

    store.dispatch(InitAudioplayerCompleted(
      audioPlayer: audioPlayer,
      plopFile: plopFile.path,
    ));
    next(action);
  };
}

_initAudioplayerMiddleware2() {
  return (Store<AppState> store, InitAudioplayer action, NextDispatcher next) {
    final AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
    File plopFile;

    getTemporaryDirectory()
        .then((tmpDir) {
          plopFile = File('${tmpDir.path}/plop.mp3');
          return rootBundle.load('assets/plop.mp3');
        })
        .then((plopAsset) =>
            plopFile.writeAsBytes(plopAsset.buffer.asUint8List()))
        .then((_) {
          audioPlayer.play(plopFile.path, isLocal: true, volume: 0.0);
          store.dispatch(InitAudioplayerCompleted(
            audioPlayer: audioPlayer,
            plopFile: plopFile.path,
          ));
        })
        .catchError((err) => store.dispatch(InitAudioplayerCompleted(
              audioPlayer: audioPlayer,
              plopFile: plopFile.path,
            )));

    next(action);
  };
}

_playPlopSoundMiddleware() {
  return (Store<AppState> store, PlayPlopSound action,
      NextDispatcher next) async {
    final audioPlayer = store.state.meta.audioPlayer;
    final plopFilePath = store.state.meta.plopFilePath;

    audioPlayer.play(plopFilePath, isLocal: true);

    next(action);
  };
}
