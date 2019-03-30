import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:lenden/store/meta/actions.dart';
import 'package:lenden/store/meta/state.dart';
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
  const HomeScreen();

  @override
  Widget build(BuildContext context) {
    return StoreBuilder(
      onInit: (store) {
        store.dispatch(StartObservingInitState());
        store.dispatch(StartObservingUserData());
        store.dispatch(StartObservingPairingState());
      },
      onDispose: (store) {
        store.dispatch(StopObservingInitState());
        store.dispatch(StopObservingUserData());
        store.dispatch(StopObservingPairingState());
      },
      builder: (context, Store<AppState> store) {
        Widget home;

        if (store.state.meta.initState != InitState.Loaded ||
            store.state.pairing.process == Process.Orienting) {
          home = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(),
              CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            ],
          );
        } else if (isPaired(store.state.pairing)) {
          home = HomePaired();
        } else {
          home = HomeUnpaired();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("Lenden"),
            actions: <Widget>[
              Visibility(
                visible: isPaired(store.state.pairing),
                child: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Unpairing?"),
                          content:
                              Text("Do you really want to remove the pairing?"),
                          actions: <Widget>[
                            FlatButton(
                              child: Text(
                                "No",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            FlatButton(
                              child: Text("Yes",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  )),
                              onPressed: () {
                                store.dispatch(Unpair());
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              )
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
