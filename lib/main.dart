import 'package:flutter/material.dart';

import 'package:redux_logging/redux_logging.dart';
import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:lenden/screens/home.dart';
import 'package:lenden/screens/loading.dart';
import 'package:lenden/store/auth/actions.dart';
import 'package:lenden/store/epics.dart';
import 'package:lenden/store/middlewares.dart';
import 'package:lenden/store/prefs/actions.dart';
import 'package:lenden/store/state.dart';
import 'package:lenden/store/reducers.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: Color(0xFF3E4F87),
          fontFamily: "Roboto",
        ),
        navigatorKey: navigatorKey,
        title: 'Lenden',
        home: LoadingScreen(),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => HomeScreen(),
        },
      ),
    );
  }
}
