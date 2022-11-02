import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'current_location_viewer_state.dart';

class CurrentLocationViewerCubit extends Cubit<CurrentLocationViewerState> {
  CurrentLocationViewerCubit() : super(LoadingCurrentLocation());

  Future<void> renderCurrentLocationText({
    required String address,
    required double longitude,
    required double latitude,
  }) async {
    emit(LoadingCurrentLocation());
    emit(CurrentLocationFetched(
      address: address,
      longitude: longitude,
      latitude: latitude,
    ));
  }
}
