// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:background_location_sender/location_service/logic/current_location_viewer/current_location_viewer_cubit.dart';
import 'package:background_location_sender/location_service/logic/location_controller/location_controller_cubit.dart';
import 'package:background_location_sender/utility/widgets/theme_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OffosGoogleMap extends StatefulWidget {
  final bool isEdit;
  final void Function(LatLng position) onPositionChanged;
  const OffosGoogleMap({
    Key? key,
    this.isEdit = false,
    required this.onPositionChanged,
  }) : super(key: key);

  @override
  State<OffosGoogleMap> createState() => _OffosGoogleMapState();
}

class _OffosGoogleMapState extends State<OffosGoogleMap> {
  final markers = <Marker>{};
  MarkerId markerId = const MarkerId("location");
  GoogleMapController? mapController;
  LatLng? latLng;

  @override
  void didChangeDependencies() {
    if (!widget.isEdit) {
      context.read<LocationControllerCubit>().locationFetchByDeviceGPS();
    }
    super.didChangeDependencies();
  }

  void renderCoordinatePoint(
    BuildContext context, {
    required double latitude,
    required double longitude,
    required String address,
  }) {
    context.read<CurrentLocationViewerCubit>().renderCurrentLocationText(
          address: address,
          latitude: latitude,
          longitude: longitude,
        );
    latLng = LatLng(latitude, longitude);
    widget.onPositionChanged.call(latLng!);
    markers.add(
      Marker(
        markerId: markerId,
        position: latLng!,
      ),
    );
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(latitude, longitude),
          18, //zoom
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocConsumer<LocationControllerCubit, LocationControllerState>(
        listener: (context, state) {
          if (state is LocationFetched) {
            renderCoordinatePoint(
              context,
              latitude: state.location.latitude,
              longitude: state.location.longitude,
              address: state.location.address,
            );
          }
        },
        builder: (context, state) {
          if (state is LocationFetched) {
            return StatefulBuilder(builder: (context, mapState) {
              return GoogleMap(
                onMapCreated: (controller) {
                  mapController = controller;
                },
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    state.location.latitude,
                    state.location.longitude,
                  ),
                  zoom: 18,
                ),
                markers: markers,
                onCameraMove: (position) {
                  widget.onPositionChanged.call(position.target);
                  if (mounted) {
                    mapState(() {
                      markers.add(
                        Marker(
                          markerId: markerId,
                          position: position.target,
                        ),
                      );
                    });
                  }
                },
              );
            });
          } else if (state is LocationError) {
            return Padding(
              padding: const EdgeInsets.all(15),
              child: Center(
                child: Text(
                  state.error,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          } else {
            return const Center(
              child: ThemeSpinner(size: 40),
            );
          }
        },
      ),
    );
  }
}
