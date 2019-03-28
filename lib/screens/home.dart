import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lenden/store/state.dart';
import 'package:lenden/store/user/actions.dart';
import 'package:lenden/store/pairing/actions.dart';
import 'package:lenden/store/pairing/selectors.dart';
import 'package:lenden/store/pairing/state.dart';
import 'package:lenden/main.dart';
import 'package:redux/redux.dart';
import 'package:lenden/widgets/organisms/home_unpaired.dart';
import 'package:lenden/widgets/organisms/home_paired.dart';

class HomeScreen extends StatelessWidget {
  final AudioPlayer audioPlayer;

  const HomeScreen(this.audioPlayer);

  @override
  Widget build(BuildContext context) {
    return StoreBuilder(
      onInit: (store) {
        store.dispatch(StartObservingUserData());
        store.dispatch(StartObservingPairingState());
      },
      onDispose: (store) {
        store.dispatch(StopObservingUserData());
        store.dispatch(StopObservingPairingState());
      },
      builder: (context, Store<AppState> store) {
        Widget home;
        if (store.state.pairing.process == Process.Orienting) {
          home = CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor),
          );
        } else if (isPaired(store.state.pairing)) {
          home = HomePaired(this.audioPlayer);
        } else {
          home = HomeUnpaired();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("Lenden"),
            actions: <Widget>[
              // action button
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  store.dispatch(Unpair());
                },
              ),
            ],
          ),
          key: scaffoldKey,
          body: Container(
            padding: EdgeInsets.all(50.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 1],
                colors: [
                  Color(0xFFFFCE41),
                  Color(0xFFBA5F0D),
                ],
              ),
            ),
            child: home,
          ),
        );
      },
    );
  }
}
