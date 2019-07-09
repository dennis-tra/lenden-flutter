import 'package:firebase_auth/firebase_auth.dart';

FirebaseUser firebaseUserFromJson(Map<String, dynamic> json) => null;
Map<String, dynamic> firebaseUserToJson(FirebaseUser user) {
  return {
    "email": user?.email,
    "displayName": user?.displayName,
    "uid": user?.uid,
    "isAnonymous": user?.isAnonymous,
    "isEmailVerified": user?.isEmailVerified,
    "phoneNumber": user?.phoneNumber,
    "photoUrl": user?.photoUrl,
    "providerId": user?.providerId,
  };
}
