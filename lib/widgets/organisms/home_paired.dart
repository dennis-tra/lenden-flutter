import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:lenden/store/state.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:path_provider/path_provider.dart';

class HomePaired extends StatelessWidget {
  final AudioPlayer audioPlayer;

  const HomePaired(this.audioPlayer);

  Future<ByteData> loadAsset() async {
    return await rootBundle.load('assets/plop.mp3');
  }

  _send() async {
    try {
      final file = new File('${(await getTemporaryDirectory()).path}/plop.mp3');

      await file.writeAsBytes((await loadAsset()).buffer.asUint8List());
      audioPlayer.play(
        file.path,
        isLocal: true,
      );

      await CloudFunctions.instance.call(functionName: 'sendPushNotification');
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder(builder: (context, Store<AppState> store) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              onPressed: this._send,
              child: Image.asset("assets/clinking-beer-mugs.png"),
            ),
            Container(),
          ]);
    });
  }
}
