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

enum Environment { DEV, BETA, PRODUCTION }

class Configuration {
  final Environment env;

  Configuration({this.env});
}

void main() {
  final config = Configuration(env: Environment.DEV);
  return start(config);
}

void start(Configuration config) async {
  var remoteDevTools = RemoteDevToolsMiddleware('localhost:8000');

  List<Middleware<AppState>> middlewares = []
    ..add(EpicMiddleware(appEpics))
    ..addAll(appMiddlewares());

  Store store;
  switch (config.env) {
    case Environment.DEV:
      store = DevToolsStore<AppState>(
        appReducer,
        initialState: AppState.initialState(),
        middleware: middlewares..add(remoteDevTools),
      );
      remoteDevTools.store = store;

      await remoteDevTools.connect();
      break;

    case Environment.BETA:
      store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
        middleware: middlewares,
      );
      break;
    case Environment.PRODUCTION:
      store = Store<AppState>(
        appReducer,
        initialState: AppState.initialState(),
        middleware: middlewares,
      );
      break;
  }

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
