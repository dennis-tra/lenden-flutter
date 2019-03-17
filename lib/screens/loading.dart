import 'package:lenden/store/meta/actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:lenden/store/state.dart';
import 'package:redux/redux.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreBuilder(
      onInit: (store) => store.dispatch(StartObservingInitState()),
      onDispose: (store) => store.dispatch(StopObservingInitState()),
      builder: (context, Store<AppState> store) {
        return Container(
          color: Colors.white,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
