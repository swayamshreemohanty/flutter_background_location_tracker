class LocationByAddress {
  final List<LocationByAddressModel> predictedLocationList;
  LocationByAddress({
    this.predictedLocationList = const [],
  });

  factory LocationByAddress.fromMap(Map<String, dynamic> map) {
    return LocationByAddress(
      predictedLocationList: List<LocationByAddressModel>.from(
          map['predictions']?.map((x) => LocationByAddressModel.fromMap(x)) ??
              const []),
    );
  }

  factory LocationByAddress.fromJson(dynamic source) =>
      LocationByAddress.fromMap(source);
}

class LocationByAddressModel {
  final String description;
  final String placeId;
  final String reference;
  final List<String> terms;
  LocationByAddressModel({
    required this.description,
    required this.placeId,
    required this.reference,
    required this.terms,
  });

  factory LocationByAddressModel.fromMap(Map<String, dynamic> map) {
    return LocationByAddressModel(
      description: map['description'] ?? '',
      placeId: map['place_id'] ?? '',
      reference: map['reference'] ?? '',
      terms: List<String>.from(map['terms']?.map((x) => x['value'])),
    );
  }
}
