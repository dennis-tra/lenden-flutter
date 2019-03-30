import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:redux_logging/redux_logging.dart';
import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';

import 'package:lenden/screens/home.dart';
import 'package:lenden/store/auth/actions.dart';
import 'package:lenden/store/epics.dart';
import 'package:lenden/store/middlewares.dart';
import 'package:lenden/store/prefs/actions.dart';
import 'package:lenden/store/meta/actions.dart';
import 'package:lenden/store/state.dart';
import 'package:lenden/store/reducers.dart';

final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() => runApp(MainApp());

class MainApp extends StatefulWidget {
  @override
  State createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  final store = Store<AppState>(
    appReducer,
    initialState: AppState.initialState(),
    middleware: []
      ..add(EpicMiddleware(appEpics))
      ..addAll(appMiddlewares())
      ..add(LoggingMiddleware.printer()),
  );

  @override
  void initState() {
    super.initState();

    store.dispatch(LoadPreferences());
    store.dispatch(LogIn());
    store.dispatch(InitAudioplayer());
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
