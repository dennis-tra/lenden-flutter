import 'package:lenden/store/auth/epics.dart';
import 'package:lenden/store/user/epics.dart';
import 'package:lenden/store/state.dart';
import 'package:lenden/store/meta/epics.dart';
import 'package:redux_epics/redux_epics.dart';

final appEpics = combineEpics<AppState>(
    []..add(authEpics())..add(userEpics())..add(metaEpics()));
