import 'package:redux/redux.dart';
import 'package:lenden/store/auth/middlewares.dart';
import 'package:lenden/store/prefs/middlewares.dart';
import 'package:lenden/store/pairing/middlewares.dart';
import 'package:lenden/store/state.dart';

List<Middleware<AppState>> appMiddlewares() {
  return []
    ..addAll(createAuthMiddleware())
    ..addAll(createPrefsMiddleware()..addAll(createPairingMiddleware()));
}
