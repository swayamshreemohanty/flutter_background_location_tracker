import 'dart:io';
import 'package:background_location_sender/utility/shared_preference/shared_preference.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseMessageRepository {
  final _firebaseFirestore = FirebaseFirestore.instance;
  final sharedpref = CustomSharedPreference();
  Future<void> sendDeviceToken({
    required String deviceToken,
  }) async {
    try {
      final docRef = _firebaseFirestore.collection("user").doc();
      String uid = "";
      final storeduid = await sharedpref.getData(key: SharedPreferenceKeys.uid);
      if (storeduid != null) {
        uid = storeduid;
      } else {
        uid = docRef.id;
        await sharedpref.storeData(key: SharedPreferenceKeys.uid, data: uid);
      }
      final data = ({
        "uid": uid,
        "push_notification_key": deviceToken,
        "device_type": Platform.isAndroid ? "android" : "ios",
      });

      return await _firebaseFirestore.collection("user").doc(uid).set(data);
    } catch (e) {
      rethrow;
    }
  }
}
