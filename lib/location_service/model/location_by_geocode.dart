class LocationByGeocode {
  final String address;
  final List<String> addressComponents;
  LocationByGeocode({
    required this.address,
    required this.addressComponents,
  });

  factory LocationByGeocode.fromMap(Map<String, dynamic> map) {
    return LocationByGeocode(
      address: map['formatted_address'] ?? 'Visakhapatnam, Andhra Pradesh',
      addressComponents: List<String>.from(
          map['address_components']?.map((x) => x['long_name'])),
    );
  }

  factory LocationByGeocode.fromJson(dynamic source) =>
      LocationByGeocode.fromMap(source['results'][0]);
}
