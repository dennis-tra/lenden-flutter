import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
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

  Map<String, dynamic> toJson() => _$UserToJson(this);
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
