import 'package:background_location_sender/firebase_options.dart';
import 'package:background_location_sender/home/logic/cubit/update_location_on_db_cubit.dart';
import 'package:background_location_sender/home/screens/home_screen.dart';
import 'package:background_location_sender/location_service/logic/location_controller/location_controller_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workmanager/workmanager.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  await FirebaseMessaging.instance.requestPermission();
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
}

const fetchBackground = "fetchBackground";

@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        await LocationControllerCubit()
            .locationFetchByDeviceGPS()
            .then((updatedLocation) => updatedLocation == null
                ? null
                : LocationControllerCubit().onLocationChanged(
                    isbackground: true,
                    updateLocationOnDbCubit: UpdateLocationOnDbCubit(),
                    longitude: updatedLocation.longitude,
                    latitude: updatedLocation.latitude,
                  ));
        break;
    }
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  // We don't need it anymore since it will be executed in background
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  Workmanager().registerPeriodicTask(
    "1",
    fetchBackground,
    frequency: const Duration(minutes: 15),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UpdateLocationOnDbCubit(),
        ),
        BlocProvider(
          create: (context) => LocationControllerCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'BG location sender',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
