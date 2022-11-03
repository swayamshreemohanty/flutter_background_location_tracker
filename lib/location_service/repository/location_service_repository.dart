// ignore_for_file: use_build_context_synchronously

import 'package:background_location_sender/location_service/key/.env.dart';
import 'package:background_location_sender/location_service/model/location_address_with_latlong.dart';
import 'package:background_location_sender/location_service/model/location_by_address.dart';
import 'package:background_location_sender/location_service/model/location_by_address_selection.dart';
import 'package:background_location_sender/location_service/model/location_by_geocode.dart';
import 'package:dio/dio.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';

class LocationServiceRepository {
  final dio = Dio();
  Location location = Location();

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
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          throw ("Require GPS service enabled");
        }
      }
      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          throw ("Require GPS service permission");
        }
      }
      final locationData = await location.getLocation();
      return await fetchLocationByCoOrdinates(
          latitude: locationData.latitude ?? 17.6968072,
          longitude: locationData.longitude ?? 83.2037749);
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
