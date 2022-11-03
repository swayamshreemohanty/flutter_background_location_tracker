import 'package:background_location_sender/utility/time_formatter.dart';

class UpdateLocation {
  final double longitude;
  final double latitude;
  final DateTime lastUpdateTime;

  UpdateLocation({
    required this.longitude,
    required this.latitude,
    required this.lastUpdateTime,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'longitude': longitude,
      'latitude': latitude,
      'lastUpdateTime': FormatDate.convertDateTimeToAMPMDateWithSeconds(
        dateTime: lastUpdateTime,
      ),
    };
  }
}
