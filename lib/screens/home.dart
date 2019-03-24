import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:lenden/store/state.dart';
import 'package:lenden/store/user/actions.dart';
import 'package:redux/redux.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_scan/barcode_scan.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreBuilder(
      onInit: (store) => store.dispatch(StartObservingUserData()),
      onDispose: (store) => store.dispatch(StartObservingUserData()),
      builder: (context, Store<AppState> store) {
        return Scaffold(
          body: Container(
            padding: EdgeInsets.all(16.0),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Pair Lenden with your friend by scanning the QR-Code on either phone", textAlign: TextAlign.center,),
                QrImage(
                  foregroundColor: Colors.black87,
                  data: store.state.auth.user.uid,
                  size: 200.0,
                ),
                FlatButton(
                  child: Text("Scan QR-Code"),
                  onPressed: () async {
                    try {
//                      var qrCode = await BarcodeScanner.scan();
//
//                      var userID = qrCode; // exchange with QR-Code parsing of URL
                      var userID = "Plb7ZfGb06fsY1ogEeY3rI5J1Vf1";
                      dynamic resp = await CloudFunctions.instance.call(functionName: 'pairUsers',parameters: {
                        "uid": userID,
                      });
                      print(resp);
                    } on CloudFunctionsException catch(e) {
                      print(e.message);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
