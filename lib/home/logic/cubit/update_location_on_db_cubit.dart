import 'package:background_location_sender/home/repository/update_location_repository.dart';
import 'package:background_location_sender/utility/shared_preference/shared_preference.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

part 'update_location_on_db_state.dart';

class UpdateLocationOnDbCubit extends Cubit<UpdateLocationOnDbState> {
  UpdateLocationOnDbCubit() : super(UpdateLocationOnDbInitial());

  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<void> updateLocation({
    required double longitude,
    required double latitude,
  }) async {
    try {
      final deviceToken = await firebaseMessaging.getToken();
      final uid =
          await CustomSharedPreference().getData(key: SharedPreferenceKeys.uid);
      if (deviceToken == null || uid == null) {
        Fluttertoast.showToast(msg: "Unable to update location on db");
        return;
      } else {
        await UpdateLocationRepository().updateLocationOnDB(
          deviceToken: deviceToken,
          uid: uid,
          longitude: longitude,
          latitude: latitude,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
