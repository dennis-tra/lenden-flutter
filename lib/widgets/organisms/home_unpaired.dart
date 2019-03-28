import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lenden/store/state.dart';
import 'package:lenden/store/pairing/actions.dart';
import 'package:lenden/widgets/molecules/qr_code.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

class HomeUnpaired extends StatelessWidget {
  _pair(Store<AppState> store) async {
    try {
      final qrCode = await BarcodeScanner.scan();
      final userID = qrCode;

      store.dispatch(Pair(uid: userID));
    } on CloudFunctionsException catch (e) {
      String errorMsg;
      switch (e.code) {
        case "NOT_FOUND":
          errorMsg = "The provided QR-Code seems invalid.";
          break;
        default:
          errorMsg = e.message;
      }
      store.dispatch(PairCompleted(error: errorMsg));
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        final errorMsg =
            "📷 Please grant camera access by navigating to Settings -> Lenden and there toggling the 'Camera' switch";
        store.dispatch(PairCompleted(error: errorMsg));
      } else {
        final errorMsg = "Hmm...";
        store.dispatch(PairCompleted(error: errorMsg));
      }
    } on FormatException {
      final errorMsg = "FormatException.";
      store.dispatch(PairCompleted(error: errorMsg));
    } on Exception catch (e) {
      final errorMsg =
          "💥💥💥 - Something went wrong with pairing your phone. Have a 🍺 and calm down.";
      store.dispatch(PairCompleted(error: errorMsg));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreBuilder(builder: (context, Store<AppState> store) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Pair Lenden with your friend by scanning the QR-Code on either phone",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0),
          ),
          SizedBox(height: 40),
          QrCode(store.state.auth.user?.uid, store.state.pairing),
          SizedBox(height: 30),
          FlatButton.icon(
            icon: Icon(Icons.camera_alt),
            label: Text("Scan QR-Code"),
            onPressed: () => this._pair(store),
          ),
        ],
      );
    });
  }
}
