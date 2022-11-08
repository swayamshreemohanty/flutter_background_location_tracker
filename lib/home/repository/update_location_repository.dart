// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:background_location_sender/utility/shared_preference/shared_preference.dart';
import 'package:background_location_sender/utility/time_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class UpdateLocationRepository {
  final _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> updateLocationOnDB({
    required String deviceToken,
    required String uid,
    required Position position,
  }) async {
    try {
      final docRef = _firebaseFirestore.collection("user").doc(uid);
      final userName = await CustomSharedPreference()
          .getData(key: SharedPreferenceKeys.userName);

      final data = ({
        "user": userName,
        "location": position.toJson(),
        'lastUpdateTime': FormatDate.convertDateTimeToAMPMDateWithSeconds(
          dateTime: DateTime.now(),
        )
      });
      return await docRef.update(data);
    } catch (e) {
      rethrow;
    }
  }
}
