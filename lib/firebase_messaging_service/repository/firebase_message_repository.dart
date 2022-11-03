import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseMessageRepository {
  final _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> sendDeviceToken({
    required String deviceToken,
  }) async {
    try {
      final docRef = _firebaseFirestore.collection("user").doc();
      final data = ({
        "uid": docRef.id,
        "push_notification_key": deviceToken,
        "device_type": Platform.isAndroid ? "android" : "ios",
      });
      return await _firebaseFirestore
          .collection("user")
          .doc(deviceToken)
          .set(data);
    } catch (e) {
      rethrow;
    }
  }
}
