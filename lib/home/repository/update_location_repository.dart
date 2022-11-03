// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:background_location_sender/home/model/update_location_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateLocationRepository {
  final _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> updateLocationOnDB({
    required String deviceToken,
    required double longitude,
    required double latitude,
  }) async {
    try {
      final docRef = _firebaseFirestore.collection("user").doc(deviceToken);
      final newLocation = UpdateLocation(
        longitude: longitude,
        latitude: latitude,
        lastUpdateTime: DateTime.now(),
      );
      final data = ({
        "location": newLocation.toMap(),
      });
      return await docRef.update(data);
    } catch (e) {
      rethrow;
    }
  }
}
