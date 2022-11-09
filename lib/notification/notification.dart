// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:background_location_sender/utility/show_snak_bar.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationService(
    this.flutterLocalNotificationsPlugin,
  );

  Future<void> createChannel(
      AndroidNotificationChannel notificationChannel) async {
    return await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(notificationChannel);
  }

  void onDidReceiveNotificationResponse(NotificationResponse details) {
    print("*******************RECEIVED 1********************");
  }

  void onDidReceiveBackgroundNotificationResponse(
      NotificationResponse details) {
    print("*******************RECEIVED 2********************");
  }

  Future initialize(BuildContext context) async {
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
    String? title,
    String? body,
    String? payload,
  }) async {
    //Demo
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

    await flutterLocalNotificationsPlugin.show(
      showNotificationId,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}
