// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:background_location_sender/location_service/widget/offos_google_map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickScreen extends StatefulWidget {
  final bool afterLogin;

  const LocationPickScreen({
    Key? key,
    this.afterLogin = false,
  }) : super(key: key);

  @override
  State<LocationPickScreen> createState() => _LocationPickScreenState();
}

class _LocationPickScreenState extends State<LocationPickScreen> {
  LatLng? latLng;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          OffosGoogleMap(
            onPositionChanged: (position) {
              latLng = LatLng(
                position.latitude,
                position.longitude,
              );
            },
          ),
        ],
      ),
    );
  }
}
