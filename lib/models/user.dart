import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String qrCode;
  final String fcmToken;
  final Timestamp updatedAt;
  final Timestamp createdAt;

  User({this.qrCode, this.fcmToken, this.updatedAt, this.createdAt});

  static User fromFirestore(DocumentSnapshot doc) {
    if (doc == null || !doc.exists) {
      return null;
    }

    return User(
        qrCode: doc["qrCode"] as String,
        fcmToken: doc["fcmToken"] as String,
        createdAt: doc["createdAt"] as Timestamp,
        updatedAt: doc["updatedAt"] as Timestamp);
  }

  @override
  String toString() {
    return "User{qrCode: $qrCode, fcmToken: $fcmToken, updatedAt: $updatedAt, createdAt: $createdAt}";
  }
}
