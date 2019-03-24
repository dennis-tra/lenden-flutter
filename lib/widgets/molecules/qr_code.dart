import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:lenden/store/state.dart';
import 'package:lenden/store/user/actions.dart';
import 'package:redux/redux.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_scan/barcode_scan.dart';

class QrCode extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StoreBuilder(
      builder: (context, Store<AppState> store) {
        return Scaffold(
          body: Container(
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
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Pair Lenden with your friend by scanning the QR-Code on either phone"),
                store.state.user.user == null ? Text("Generating QR-Code...") : Text(""),
                store.state.user.user != null ? QrImage(
                  foregroundColor: Colors.black87,
                  data: store.state.user.user?.qrCode,
                  size: 200.0,
                ): Text(""),
                FlatButton(child: Text("Scan QR-Code"),onPressed: () async {
                  try {
                    var result = await BarcodeScanner.scan();
                  } catch(e) {
                    showDialog(context: e);
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
