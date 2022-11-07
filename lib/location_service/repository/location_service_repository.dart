// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:background_location_sender/location_service/key/.env.dart';
import 'package:background_location_sender/location_service/model/location_address_with_latlong.dart';
import 'package:background_location_sender/location_service/model/location_by_address.dart';
import 'package:background_location_sender/location_service/model/location_by_address_selection.dart';
import 'package:background_location_sender/location_service/model/location_by_geocode.dart';

class LocationServiceRepository {
  final dio = Dio();

  LocationServiceRepository();

  Future<LocationAddressWithLatLong> fetchLocationByAddress({
    required String selectedAddress,
  }) async {
    return await dio
        .get(
            'https://maps.googleapis.com/maps/api/geocode/json?address=$selectedAddress&key=$googleMapAPI')
        .then((response) {
      if (response.data['error_message'] != null) {
        throw (response.data['error_message']);
      } else {
        final data =
            LocationByAddressSelectionModel.fromMap(response.data).result.first;
        return LocationAddressWithLatLong(
          address: data.formatAddress,
          latitude: data.latitude,
          longitude: data.longitude,
          //the null handler cordinates are of Visakhapatnam
        );
      }
    });
  }

  Future<LocationAddressWithLatLong> fetchLocationByCoOrdinates({
    required double latitude,
    required double longitude,
  }) async {
    return await dio
        .get(
            'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$googleMapAPI')
        .then((response) {
      if (response.data['error_message'] != null) {
        throw (response.data['error_message']);
      } else {
        return LocationAddressWithLatLong(
          address: LocationByGeocode.fromJson(response.data).address,
          latitude: latitude,
          longitude: longitude,
          //the null handler cordinates are of Visakhapatnam
        );
      }
    });
  }

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
        return await fetchLocationByCoOrdinates(
          latitude: locationData.latitude,
          longitude: locationData.longitude,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LocationByAddressModel>> _fetchAddressByQuery(
      {required String input}) async {
    try {
      // generate a new token here
      final sessionToken = const Uuid().v4();
      return await dio
          .get(
              "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=address&language=en&key=$googleMapAPI&sessiontoken=$sessionToken")
          .then((response) {
        if (response.data['error_message'] != null) {
          throw (response.data['error_message']);
        } else {
          return LocationByAddress.fromJson(response.data)
              .predictedLocationList;
        }
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<List<LocationByAddressModel>> getAddressSuggestions(
    String query,
  ) async {
    try {
      final addressPredictionList = await _fetchAddressByQuery(input: query);
      return addressPredictionList.where((element) {
        final descriptionLower = element.description.toLowerCase();
        final queryLower = query.toLowerCase();
        return descriptionLower.contains(queryLower);
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
