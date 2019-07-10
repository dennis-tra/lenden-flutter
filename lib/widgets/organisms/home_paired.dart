import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:lenden/store/state.dart';
import 'package:lenden/store/meta/actions.dart';
import 'package:lenden/widgets/molecules/favourite_button.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

class HomePaired extends StatelessWidget {
  HomePaired();

  _send(Store<AppState> store) async {
    try {
      store.dispatch(PlayPlopSound());
      await CloudFunctions.instance.getHttpsCallable(functionName: 'sendPushNotification').call();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder(builder: (context, Store<AppState> store) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // FavouriteButton(),
            FlatButton(
              onPressed: () => this._send(store),
              child: Image.asset("assets/clinking-beer-mugs.png"),
            ),
            Container(),
          ]);
    });
  }
}
