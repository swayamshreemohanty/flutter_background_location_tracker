// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: use_build_context_synchronously
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:background_location_sender/home/logic/cubit/update_location_on_db_cubit.dart';
import 'package:background_location_sender/location_service/model/location_address_with_latlong.dart';
import 'package:background_location_sender/location_service/repository/location_service_repository.dart';
import 'package:background_location_sender/notification/notification.dart';

part 'location_controller_state.dart';

class LocationControllerCubit extends Cubit<LocationControllerState> {
  final LocationServiceRepository locationServiceRepository;

  LocationControllerCubit({
    required this.locationServiceRepository,
  }) : super(StopLocationFetch());

  LocationAddressWithLatLong? selectedLocation;

  Future<LocationAddressWithLatLong> _getlocationSetCoOrdinates(
      {required double latitude, required double longitude}) async {
    try {
      return await locationServiceRepository.fetchLocationByCoOrdinates(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      rethrow;
    }
  }

  Future<void> stopLocationFetch() async {
    emit(LoadingLocation());

    emit(StopLocationFetch());
  }

  Future<void> onLocationChanged({
    bool isbackground = false,
    bool stopUpdateScreen = false,
    required double latitude,
    required double longitude,
    required UpdateLocationOnDbCubit updateLocationOnDbCubit,
  }) async {
    try {
      print("********************");
      print(stopUpdateScreen);
      if (isbackground) {
        //////////
        final localNotification =
            Notification(FlutterLocalNotificationsPlugin());
        localNotification.showNotificationWithoutSound(
          latitude: latitude,
          longitude: longitude,
        );
        //////////
      } else if (!stopUpdateScreen) {
        emit(LoadingLocation());
        emit(LocationFetched(
          location: LocationAddressWithLatLong(
            address: "",
            latitude: latitude,
            longitude: longitude,
          ),
        ));
      }
      updateLocationOnDbCubit.updateLocation(
        longitude: longitude,
        latitude: latitude,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      emit(LocationError(error: e.toString()));
    }
  }

  Future<LocationAddressWithLatLong?> locationFetchByDeviceGPS({
    bool allowSetLocation = false,
  }) async {
    try {
      emit(LoadingLocation());

      Fluttertoast.showToast(msg: "Fetching address...");
      selectedLocation =
          await locationServiceRepository.fetchLocationByDeviceGPS();

      emit(LocationFetched(
        location: selectedLocation!,
        allowSetLocation: allowSetLocation,
      ));

      return selectedLocation;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());

      emit(LocationError(error: e.toString()));

      return null;
    }
  }

  Future<void> getLocationByAddress({required String selectedAddress}) async {
    try {
      Fluttertoast.showToast(msg: "Fetching address...");
      selectedLocation = await locationServiceRepository.fetchLocationByAddress(
          selectedAddress: selectedAddress);
      emit(LocationFetched(location: selectedLocation!));
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      emit(LocationError(error: e.toString()));
    }
  }

  Future<void> getLocationByCoOrdinates({
    required LatLng latLng,
    bool allowSetLocation = false,
  }) async {
    try {
      Fluttertoast.showToast(msg: "Collecting location details...");

      selectedLocation = await _getlocationSetCoOrdinates(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
      );

      emit(LocationFetched(
        location: selectedLocation!,
        allowSetLocation: allowSetLocation,
      ));
      return;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      return;
    }
  }
}
