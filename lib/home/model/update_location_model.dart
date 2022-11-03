// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UpdateLocation {
  final double longitude;
  final double latitude;
  final DateTime updateTime;

  UpdateLocation({
    required this.longitude,
    required this.latitude,
    required this.updateTime,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'longitude': longitude,
      'latitude': latitude,
      'updateTime': updateTime.millisecondsSinceEpoch,
    };
  }

  factory UpdateLocation.fromMap(Map<String, dynamic> map) {
    return UpdateLocation(
      longitude: (map['longitude'] ?? 0.0) as double,
      latitude: (map['latitude'] ?? 0.0) as double,
      updateTime:
          DateTime.fromMillisecondsSinceEpoch((map['updateTime'] ?? 0) as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory UpdateLocation.fromJson(String source) =>
      UpdateLocation.fromMap(json.decode(source) as Map<String, dynamic>);
}
