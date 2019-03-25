import 'package:cloud_firestore/cloud_firestore.dart';

class Pairing {
  // list of the IDs of paired users
  final List<String> userIds;

  Pairing({this.userIds});

  static Pairing fromFirestore(DocumentSnapshot doc) {
    if (doc == null || !doc.exists) {
      return null;
    }

    return Pairing(
      userIds: List<String>.from(doc.data["user_ids"].keys),
    );
  }

  @override
  String toString() {
    return "Pairing{userIds: $userIds}";
  }
}
