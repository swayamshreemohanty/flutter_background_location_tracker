import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class LocationByAddressSelectionModel {
  final List<LocationByAddressSelectionData> result;
  LocationByAddressSelectionModel({
    required this.result,
  });

  factory LocationByAddressSelectionModel.fromMap(Map<String, dynamic> map) {
    return LocationByAddressSelectionModel(
      result: List<LocationByAddressSelectionData>.from(
        map['results'].map((x) => LocationByAddressSelectionData.fromMap(x)) ??
            const [],
      ),
    );
  }
}

class LocationByAddressSelectionData {
  final String formatAddress;
  final double latitude;
  final double longitude;
  LocationByAddressSelectionData({
    required this.formatAddress,
    required this.latitude,
    required this.longitude,
  });

  factory LocationByAddressSelectionData.fromMap(Map<String, dynamic> map) {
    return LocationByAddressSelectionData(
      formatAddress: (map['formatted_address'] ?? '') as String,
      latitude: (map["geometry"]["location"]["lat"] ?? 0.0) as double,
      longitude: (map["geometry"]["location"]["lng"] ?? 0.0) as double,
    );
  }

  factory LocationByAddressSelectionData.fromJson(String source) =>
      LocationByAddressSelectionData.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
