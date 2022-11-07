// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:ui';
import 'package:background_location_sender/firebase_options.dart';
import 'package:background_location_sender/home/logic/cubit/update_location_on_db_cubit.dart';
import 'package:background_location_sender/location_service/logic/location_controller/location_controller_cubit.dart';
import 'package:background_location_sender/location_service/repository/location_service_repository.dart';
import 'package:background_location_sender/utility/shared_preference/shared_preference.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

@pragma('vm:entry-point')
void onStart(
  ServiceInstance service,
  // LocationControllerCubit locationControllerCubit,
  // UpdateLocationOnDbCubit updateLocationOnDbCubit,
) async {
  DartPluginRegistrant.ensureInitialized();
  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  double longitude = 0;
  double latitude = 0;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // final oldLocation = await Location().getLocation();
  // print("OLD LOCATION PACKAGE");
  // print(oldLocation.longitude);
  // print(oldLocation.latitude);
  // print("xxxxxxxxxxxxxxxx");

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

  // bring to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        final location = await _determinePosition();
        if (longitude != location.longitude || latitude != location.latitude) {
          longitude = location.longitude;
          latitude = location.latitude;
          await UpdateLocationOnDbCubit().updateLocation(
            longitude: location.longitude,
            latitude: location.latitude,
          );
          flutterLocalNotificationsPlugin.show(
            888,
            'COOL LOCATION SERVICE',
            'Latitude: ${location.latitude}, Longitude: ${location.longitude}',
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
        }
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
