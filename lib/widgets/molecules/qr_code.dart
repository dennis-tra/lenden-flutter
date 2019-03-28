import 'package:flutter/material.dart';
import 'package:lenden/store/pairing/state.dart';

import 'package:qr_flutter/qr_flutter.dart';

class QrCode extends StatelessWidget {
  final String code;
  final PairingState pairingState;

  const QrCode(this.code, this.pairingState);

  @override
  Widget build(BuildContext context) {
    if (this.code == null || this.code == "") {
      return Text("No QRCode given");
    }

    switch (this.pairingState.process) {
      case Process.Settled:
        return QrImage(
          foregroundColor: Colors.black87,
          data: code,
          size: 200.0,
        );
      default:
        return SizedBox(
          height: 200.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              )
            ],
          ),
        );
    }
  }
}
