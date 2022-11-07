// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: use_build_context_synchronously
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:background_location_sender/location_service/model/location_address_with_latlong.dart';
import 'package:background_location_sender/location_service/repository/location_service_repository.dart';

part 'location_controller_state.dart';

class LocationControllerCubit extends Cubit<LocationControllerState> {
  final LocationServiceRepository locationServiceRepository;

  LocationControllerCubit({
    required this.locationServiceRepository,
  }) : super(StopLocationFetch());

  LocationAddressWithLatLong? selectedLocation;

  Future<void> stopLocationFetch() async {
    emit(LoadingLocation());
    emit(StopLocationFetch());
  }

  Future<void> onLocationChanged({
    required double latitude,
    required double longitude,
  }) async {
    try {
      emit(LoadingLocation());
      emit(LocationFetched(
        location: LocationAddressWithLatLong(
          address: "",
          latitude: latitude,
          longitude: longitude,
        ),
      ));
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
}
