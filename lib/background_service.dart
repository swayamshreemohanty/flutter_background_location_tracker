// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:ui';
import 'package:background_location_sender/firebase_options.dart';
import 'package:background_location_sender/home/logic/cubit/update_location_on_db_cubit.dart';
import 'package:background_location_sender/notification/notification.dart';
import 'package:background_location_sender/utility/shared_preference/shared_preference.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

const String notificationChannelId = "foreground_service";
const int foregroundServiceNotificationId = 888;
const String initialNotificationTitle = "TRACK YOUR LOCATION";
const String initialNotificationContent = "Initializing";

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

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

  // bring to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.always) {
          final username = await CustomSharedPreference()
                  .getData(key: SharedPreferenceKeys.userName) ??
              "User";
          Geolocator.getPositionStream().listen((Position position) async {
            await UpdateLocationOnDbCubit().updateLocation(
              position: position,
            );

            await NotificationService().showNotification(
              showNotificationId: foregroundServiceNotificationId,
              title: "Hii, $username.",
              body:
                  'Your Latitude: ${position.latitude}, Longitude: ${position.longitude}',
              payload: "service",
              androidNotificationDetails: const AndroidNotificationDetails(
                notificationChannelId,
                notificationChannelId,
                icon: 'ic_bg_service_small',
                ongoing: true,
              ),
            );
          });
        }
      }
    }
  });
}

class BackgroundService {
  //Get instance for flutter background service plugin
  final FlutterBackgroundService flutterBackgroundService =
      FlutterBackgroundService();

  /////

  BackgroundService();

  FlutterBackgroundService get instance => flutterBackgroundService;

  Future<void> initializeService() async {
    //OPTIONAL, using custom notification channel id
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId, // id
      initialNotificationTitle, // title
      description: 'This channel is used for important notifications.',
      // description
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
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        foregroundServiceNotificationId: foregroundServiceNotificationId,
        initialNotificationTitle: initialNotificationTitle,
        initialNotificationContent: initialNotificationContent,
      ),
      //Currently IOS setup is not completed.
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: true,
        // this will be executed when app is in foreground in separated isolate
        onForeground: onStart,
      ),
    );
    await flutterBackgroundService.startService();
  }

  Future<void> startService() async {
    await flutterBackgroundService.startService();
    flutterBackgroundService.invoke("start_service");
  }

  void stopService() {
    flutterBackgroundService.invoke("stop_service");
  }
}
