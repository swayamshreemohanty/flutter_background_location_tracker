// ignore_for_file: use_build_context_synchronously
import 'package:background_location_sender/home/logic/cubit/update_location_on_db_cubit.dart';
import 'package:background_location_sender/location_service/model/location_address_with_latlong.dart';
import 'package:background_location_sender/location_service/repository/location_service_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

part 'location_controller_state.dart';

class LocationControllerCubit extends Cubit<LocationControllerState> {
  LocationControllerCubit() : super(LoadingLocation());

  LocationAddressWithLatLong? selectedLocation;

  Future<LocationAddressWithLatLong> _getlocationSetCoOrdinates(
      {required double latitude, required double longitude}) async {
    try {
      return await LocationServiceRepository().fetchLocationByCoOrdinates(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      rethrow;
    }
  }

  Future<void> onLocationChanged({
    required LocationData currentLocation,
    required UpdateLocationOnDbCubit updateLocationOnDbCubit,
  }) async {
    try {
      emit(LoadingLocation());
      final latitude = currentLocation.latitude ?? 0;
      final longitude = currentLocation.longitude ?? 0;
      emit(LocationFetched(
        location: LocationAddressWithLatLong(
          address: "",
          latitude: latitude,
          longitude: longitude,
        ),
      ));
      updateLocationOnDbCubit.updateLocation(
        longitude: longitude,
        latitude: latitude,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      emit(LocationError(error: e.toString()));
    }
  }

  Future<void> locationFetchByDeviceGPS({bool allowSetLocation = false}) async {
    try {
      emit(LoadingLocation());
      Fluttertoast.showToast(msg: "Fetching address...");
      selectedLocation =
          await LocationServiceRepository().fetchLocationByDeviceGPS();
      emit(LocationFetched(
        location: selectedLocation!,
        allowSetLocation: allowSetLocation,
      ));
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      emit(LocationError(error: e.toString()));
    }
  }

  Future<void> getLocationByAddress({required String selectedAddress}) async {
    try {
      Fluttertoast.showToast(msg: "Fetching address...");
      selectedLocation = await LocationServiceRepository()
          .fetchLocationByAddress(selectedAddress: selectedAddress);
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
