// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'current_location_viewer_cubit.dart';

abstract class CurrentLocationViewerState extends Equatable {
  const CurrentLocationViewerState();

  @override
  List<Object> get props => [];
}

class LoadingCurrentLocation extends CurrentLocationViewerState {}

class CurrentLocationFetched extends CurrentLocationViewerState {
  final String address;
  final double latitude;
  final double longitude;
  const CurrentLocationFetched({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
  @override
  List<Object> get props => [address, latitude, longitude];
}

class CurrentLocationError extends CurrentLocationViewerState {
  final String error;
  const CurrentLocationError({required this.error});
  @override
  List<Object> get props => [error];
}
