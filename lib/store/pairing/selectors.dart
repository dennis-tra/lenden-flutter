import 'package:lenden/store/pairing/state.dart';

isPaired(PairingState state) {
  return state.pairing != null;
}
