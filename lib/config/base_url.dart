import 'package:background_location_sender/config/.env.dart';
import 'package:dio/dio.dart';

class ApiBaseUrl {
  static BaseOptions _options() => BaseOptions(
        baseUrl: "$baseUrl/v1",
        connectTimeout: 60 * 1000, // 60 seconds
        receiveTimeout: 60 * 1000, // 60 seconds

        responseType: ResponseType.json,
        contentType: Headers.jsonContentType,
      );

  Future<Dio> userDio() async {
    try {
      return Dio(_options());
    } catch (e) {
      rethrow;
    }
  }
}
