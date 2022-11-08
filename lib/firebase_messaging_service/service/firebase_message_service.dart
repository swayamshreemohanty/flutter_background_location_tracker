import 'package:background_location_sender/firebase_messaging_service/repository/firebase_message_repository.dart';
import 'package:background_location_sender/utility/shared_preference/shared_preference.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FirebaseMessageService {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final sharedpref = CustomSharedPreference();

  Future<void> generateFirebaseMessageToken() async {
    try {
      String deviceToken = "";
      final storedDeviceToken = await CustomSharedPreference()
          .getData(key: SharedPreferenceKeys.notificationToken);

      if (storedDeviceToken != null) {
        deviceToken = storedDeviceToken;
      } else {
        deviceToken = await firebaseMessaging.getToken() ?? "";
        await sharedpref.storeData(
          key: SharedPreferenceKeys.notificationToken,
          data: deviceToken,
        );
      }

      if (deviceToken.isNotEmpty) {
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
