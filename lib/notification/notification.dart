// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Future initialize() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings(
            "@mipmap/ic_launcher"); //'@mipmap/ic_launcher'

    DarwinInitializationSettings darwinInitializationSettings =
        const DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future showNotification({
    int showNotificationId = 0,
    required AndroidNotificationDetails androidNotificationDetails,
    //
    required String title,
    required String body,
    required String? payload,
  }) async {
    //  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    //   channelId,
    //   channelName,
    //   channelDescription: channelDescription,
    //   playSound: false,
    //   importance: Importance.max,
    //   priority: Priority.high,
    // );

    var platformChannelSpecifics =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      showNotificationId,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}
