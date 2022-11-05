// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'package:background_location_sender/firebase_options.dart';
import 'package:background_location_sender/home/logic/cubit/update_location_on_db_cubit.dart';
import 'package:background_location_sender/location_service/logic/location_controller/location_controller_cubit.dart';
import 'package:background_location_sender/location_service/repository/location_service_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:location/location.dart';

@pragma('vm:entry-point')
void onStart(
  ServiceInstance service,
  // LocationControllerCubit locationControllerCubit,
  // UpdateLocationOnDbCubit updateLocationOnDbCubit,
) async {
  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (service is AndroidServiceInstance) {
    service.on('start_service').listen((event) async {
      await service.setAsForegroundService();
    });

    service.on('setAsForeground').listen((event) async {
      await service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) async {
      await service.setAsBackgroundService();
    });
  }

  service.on("stop_service").listen((event) async {
    await service.stopSelf();
  });
  double num1 = 0;
  double num2 = 10;

  // bring to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        /// OPTIONAL for use custom notification
        /// the notification id must be equals with AndroidConfiguration when you call configure() method.
        flutterLocalNotificationsPlugin.show(
          888,
          'COOL SERVICE',
          'AWESOME COUNTER: $num1, $num2',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'AWESOME SERVICE:',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
          payload: "service",
        );

        // final location = await Location().getLocation();

        await UpdateLocationOnDbCubit().updateLocation(
          longitude: num1,
          latitude: num2,
        );
        print("+++++++++++++++++++++++++++++");
        print(num1);
        print(num2);
        num1 += 1;
        num2 += 1;
        // if you don't using custom notification, uncomment this
        // service.setForegroundNotificationInfo(
        //   title: "My App Service",
        //   content: "Updated at ${DateTime.now()}",
        // );
      }
    }
  });
}

class BackgroundService {
  //Get instance for flutter background service plugin
  final FlutterBackgroundService flutterBackgroundService =
      FlutterBackgroundService();
  //Background service configuration params///
  final String notificationChannelId;
  final String initialNotificationTitle;
  final String initialNotificationContent;
  final int foregroundServiceNotificationId;
  /////

  BackgroundService({
    required this.notificationChannelId,
    required this.initialNotificationTitle,
    required this.initialNotificationContent,
    required this.foregroundServiceNotificationId,

    // required this.notificationChannel,
  });

  FlutterBackgroundService get instance => flutterBackgroundService;

  Future<void> initializeService() async {
    print("*********");

    // /// OPTIONAL, using custom notification channel id
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground', // id
      'MY FOREGROUND SERVICE', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.low, // importance must be at low or higher level
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await flutterBackgroundService.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,
        // auto start service
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: initialNotificationTitle,
        initialNotificationContent: initialNotificationContent,
        foregroundServiceNotificationId: foregroundServiceNotificationId,
      ),
      //Currently IOS setup is not completed.
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: true,
        // this will be executed when app is in foreground in separated isolate
        // onForeground: (service) {
        //   return onStart(
        //     service,
        //     locationControllerCubit,
        //     updateLocationOnDbCubit,
        //   );
        // },
      ),
    );
    stopService();
  }

  void startService() {
    flutterBackgroundService.startService();
    flutterBackgroundService.invoke("start_service");
  }

  void stopService() {
    flutterBackgroundService.invoke("stop_service");
  }
}
