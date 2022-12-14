// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'location_controller_cubit.dart';

abstract class LocationControllerState extends Equatable {
  const LocationControllerState();

  @override
  List<Object> get props => [];
}

class LoadingLocation extends LocationControllerState {}

class LocationFetched extends LocationControllerState {
  final bool allowSetLocation;
  final LocationAddressWithLatLong location;
  const LocationFetched({
    this.allowSetLocation = false,
    required this.location,
  });
  @override
  List<Object> get props => [location, allowSetLocation];
}

class LocationError extends LocationControllerState {
  final String error;
  const LocationError({required this.error});
  @override
  List<Object> get props => [error];
}
