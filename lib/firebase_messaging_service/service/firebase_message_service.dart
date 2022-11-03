import 'package:background_location_sender/firebase_messaging_service/repository/firebase_message_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FirebaseMessageService {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<void> generateFirebaseMessageToken() async {
    try {
      final deviceToken = await firebaseMessaging.getToken();
      if (deviceToken != null) {
        await FirebaseMessageRepository()
            .sendDeviceToken(deviceToken: deviceToken);
      } else {
        throw ("Unable to register device");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> deleteFirebaseMessageToken() async {
    try {
      await firebaseMessaging.deleteToken();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
