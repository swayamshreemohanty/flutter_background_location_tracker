// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notification {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Notification(
    this.flutterLocalNotificationsPlugin,
  ) {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future showNotificationWithoutSound({
    required double latitude,
    required double longitude,
  }) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      '1',
      'location-bg',
      channelDescription: 'fetch location in background',
      playSound: false,
      importance: Importance.max,
      priority: Priority.high,
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Location Updated',
      "Latitude: $latitude, Longitude: $longitude",
      platformChannelSpecifics,
      payload: '',
    );
  }
}
