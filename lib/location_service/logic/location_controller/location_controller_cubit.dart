// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: use_build_context_synchronously
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:background_location_sender/location_service/repository/location_service_repository.dart';
import 'package:geolocator/geolocator.dart';

part 'location_controller_state.dart';

class LocationControllerCubit extends Cubit<LocationControllerState> {
  final LocationServiceRepository locationServiceRepository;

  LocationControllerCubit({
    required this.locationServiceRepository,
  }) : super(StopLocationFetch());

  Future<void> stopLocationFetch() async {
    emit(LoadingLocation());
    emit(StopLocationFetch());
  }

  Future<void> onLocationChanged({
    required Position location,
  }) async {
    try {
      emit(LoadingLocation());
      emit(LocationFetched(location: location));
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      emit(LocationError(error: e.toString()));
    }
  }

  Future<Position?> locationFetchByDeviceGPS() async {
    try {
      emit(LoadingLocation());

      Fluttertoast.showToast(msg: "Fetching address...");
      final selectedLocation =
          await locationServiceRepository.fetchLocationByDeviceGPS();

      emit(LocationFetched(location: selectedLocation));

      return selectedLocation;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());

      emit(LocationError(error: e.toString()));

      return null;
    }
  }
}
