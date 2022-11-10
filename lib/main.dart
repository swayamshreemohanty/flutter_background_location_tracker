import 'package:background_location_sender/firebase_options.dart';
import 'package:background_location_sender/home/logic/cubit/update_location_on_db_cubit.dart';
import 'package:background_location_sender/home/screens/home_screen.dart';
import 'package:background_location_sender/location_service/logic/location_controller/location_controller_cubit.dart';
import 'package:background_location_sender/location_service/repository/location_service_repository.dart';
import 'package:background_location_sender/notification/notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final locationControllerCubit = LocationControllerCubit(
  locationServiceRepository: LocationServiceRepository(),
);

final notificationService =
    NotificationService(FlutterLocalNotificationsPlugin());

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

Future<void> setupFlutterNotifications() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  channel = const AndroidNotificationChannel(
    'background_high_importance_channel', // id
    'High Importance Bckground Notifications', // title
    description:
        'This channel is used for background notifications.', // description
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound("bellsound"),
  );

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await notificationService.createChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null) {
    notificationService.showNotification(
      androidNotificationDetails: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        sound: const RawResourceAndroidNotificationSound("bellsound"),

        // TODO add a proper drawable resource to android, for now using
        //      one that already exists in example app.
        // icon: 'launch_background',
      ),
      showNotificationId: notification.hashCode,
      title: "(Background) ${notification.title}",
      body: "(Background) ${notification.body}",
      payload: "service",
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  showFlutterNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print(
      '***************Handling a background message ${message.messageId}***********');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // We don't need it anymore since it will be executed in background

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: notificationService,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => UpdateLocationOnDbCubit(),
          ),
          BlocProvider.value(value: locationControllerCubit),
        ],
        child: MaterialApp(
          title: 'Track Your Location',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
