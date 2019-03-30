import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String fcmToken;

  User({this.fcmToken});

  static User fromFirestore(DocumentSnapshot doc) {
    if (doc == null || !doc.exists) {
      return null;
    }

    return User(
      fcmToken: doc["fcmToken"] as String,
    );
  }

  @override
  String toString() {
    return "User{fcmToken: $fcmToken}";
  }
}
