import 'package:background_location_sender/home/repository/update_location_repository.dart';
import 'package:background_location_sender/utility/shared_preference/shared_preference.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

part 'update_location_on_db_state.dart';

class UpdateLocationOnDbCubit extends Cubit<UpdateLocationOnDbState> {
  UpdateLocationOnDbCubit() : super(UpdateLocationOnDbInitial());

  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<void> updateLocation({
    required Position position,
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
          position: position,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
