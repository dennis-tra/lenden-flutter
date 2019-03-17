import 'package:lenden/store/state.dart';

bool isFirstLaunch(AppState state) => state.prefs.launchCount == 0;
