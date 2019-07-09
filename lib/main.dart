import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:redux_logging/redux_logging.dart';
import 'package:redux/redux.dart';
import 'package:redux_dev_tools/redux_dev_tools.dart';
import 'package:redux_epics/redux_epics.dart';

import 'package:lenden/screens/home.dart';
import 'package:lenden/store/auth/actions.dart';
import 'package:lenden/store/epics.dart';
import 'package:lenden/store/middlewares.dart';
import 'package:lenden/store/prefs/actions.dart';
import 'package:lenden/store/meta/actions.dart';
import 'package:lenden/store/state.dart';
import 'package:lenden/store/reducers.dart';
import 'package:redux_remote_devtools/redux_remote_devtools.dart';

final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  var remoteDevtools = RemoteDevToolsMiddleware('localhost:8000');

  final store = DevToolsStore<AppState>(
    appReducer,
    initialState: AppState.initialState(),
    middleware: []
      ..add(EpicMiddleware(appEpics))
      ..addAll(appMiddlewares())
      ..add(remoteDevtools),
  );
  remoteDevtools.store = store;

  await remoteDevtools.connect();

  store.dispatch(LoadPreferences());
  store.dispatch(StartObservingAuthState());
  store.dispatch(LogIn());
  store.dispatch(InitAudioplayer());

  return runApp(MainApp(store: store));
}

class MainApp extends StatefulWidget {
  final Store<AppState> store;

  MainApp({this.store});

  @override
  State createState() => MainAppState(store: store);
}

class MainAppState extends State<MainApp> {
  final Store<AppState> store;

  MainAppState({this.store});

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: Color(0xFFBA5F0D),
          accentColor: Colors.white,
          fontFamily: "Roboto",
        ),
        navigatorKey: navigatorKey,
        title: 'Lenden',
        home: HomeScreen(),
      ),
    );
  }
}
