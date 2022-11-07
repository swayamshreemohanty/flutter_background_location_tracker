// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: use_build_context_synchronously

import 'package:geolocator/geolocator.dart';
import 'package:background_location_sender/location_service/model/location_address_with_latlong.dart';

class LocationServiceRepository {
  LocationServiceRepository();

  Future<LocationAddressWithLatLong> fetchLocationByDeviceGPS() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        throw ('Location services are disabled.');
      } else {
        permission = await Geolocator.checkPermission();

        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            throw ('Location permissions are denied');
          }
        }
        if (permission == LocationPermission.deniedForever) {
          // Permissions are denied forever, handle appropriately.
          throw ('Location permissions are permanently denied, we cannot request permissions.');
        }
        if (permission == LocationPermission.whileInUse) {
          permission = await Geolocator.requestPermission();
          // Permissions are denied forever, handle appropriately.
          throw ('Set the location permissions to Always.');
        }

        final locationData = await Geolocator.getCurrentPosition();
        // return await fetchLocationByCoOrdinates(
        //   latitude: locationData.latitude,
        //   longitude: locationData.longitude,
        // );

        return LocationAddressWithLatLong(
          address: "",
          latitude: locationData.latitude,
          longitude: locationData.longitude,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
