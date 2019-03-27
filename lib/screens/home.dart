import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:lenden/store/state.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lenden/store/user/actions.dart';
import 'package:lenden/store/pairing/actions.dart';
import 'package:redux/redux.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_scan/barcode_scan.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreBuilder(
      onInit: (store) {
        store.dispatch(StartObservingUserData());
        store.dispatch(StartObservingPairingState());
      },
      onDispose: (store) {
        store.dispatch(StopObservingUserData());
        store.dispatch(StopObservingPairingState());
      },
      builder: (context, Store<AppState> store) {
        return Scaffold(
          key: _scaffoldKey,
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
            child: store.state.pairing.pairing == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Pair Lenden with your friend by scanning the QR-Code on either phone",
                        textAlign: TextAlign.center,
                      ),
                      QrImage(
                        foregroundColor: Colors.black87,
                        data: store.state.auth.user.uid,
                        size: 200.0,
                      ),
                      FlatButton(
                        child: Text("Scan QR-Code"),
                        onPressed: () async {
                          try {
                            final qrCode = await BarcodeScanner.scan();
                            final userID = qrCode;

                            await CloudFunctions.instance
                                .call(functionName: 'pairUsers', parameters: {
                              "uid": userID,
                            });

                            final _firebaseMessaging = FirebaseMessaging();
                            _firebaseMessaging.requestNotificationPermissions();
                          } on CloudFunctionsException catch (e) {
                            String errorMsg;
                            switch (e.code) {
                              case "NOT_FOUND":
                                errorMsg =
                                    "The provided QR-Code seems invalid.";
                                break;
                              default:
                                errorMsg = e.message;
                            }

                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text('Error: ${errorMsg}'),
                              duration: Duration(seconds: 5),
                            ));
                          } on PlatformException catch (e) {
                            if (e.code == BarcodeScanner.CameraAccessDenied) {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text(
                                    "📷 Please grant camera access by navigating to Settings -> Lenden and there toggling the 'Camera' switch"),
                                duration: Duration(seconds: 10),
                              ));
                            } else {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text("Hmm!"),
                                duration: Duration(seconds: 5),
                              ));
                            }
                          } on FormatException {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text("FormatException."),
                              duration: Duration(seconds: 5),
                            ));
                          } on Exception catch (e) {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text(
                                  "💥💥💥 - Something went wrong with pairing your phone. Have a 🍺 and calm down."),
                              duration: Duration(seconds: 5),
                            ));
                          }
                        },
                      ),
                      Text(
                        "${store.state.pairing.pairing}",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Text("Connected!"),
                        FlatButton(
                          child: Text(
                            "🍺",
                          ),
                          onPressed: () async {
                            await CloudFunctions.instance
                                .call(functionName: 'sendPushNotification');
                          },
                        ),
                        Text(
                          "${store.state.pairing.pairing}",
                          textAlign: TextAlign.center,
                        ),
                      ]),
          ),
        );
      },
    );
  }
}
