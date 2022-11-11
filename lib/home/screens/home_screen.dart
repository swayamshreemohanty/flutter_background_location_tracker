// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'dart:async';
import 'package:background_location_sender/firebase_messaging_service/service/firebase_message_service.dart';
import 'package:background_location_sender/home/screens/order_screen.dart';
import 'package:background_location_sender/home/screens/ring_screen.dart';
import 'package:background_location_sender/home/widgets/custom_text_form_field.dart';
import 'package:background_location_sender/notification/notification.dart';
import 'package:background_location_sender/utility/shared_preference/shared_preference.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:background_location_sender/background_service.dart';
import 'package:background_location_sender/location_service/logic/location_controller/location_controller_cubit.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final userNameTextController = TextEditingController();
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  Future<void> requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    // if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    //   Fluttertoast.showToast(msg: "User granted permission");
    // } else if (settings.authorizationStatus ==
    //     AuthorizationStatus.provisional) {
    //   Fluttertoast.showToast(msg: "User granted provisional permission");
    // } else {
    //   Fluttertoast.showToast(msg: "User declined or has not accept permission");
    // }
  }

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // print('***********Got a message whilst in the foreground!************');
      // print('Message data: ${message.data}');
      if (message.notification != null) {
        // print('Message also contained a notification: ${message.notification}');
        // await context.read<NotificationService>().showNotification(
        //       androidNotificationDetails: const AndroidNotificationDetails(
        //         "firebase",
        //         "firebase",
        //         importance: Importance.high,
        //         playSound: true,
        //       ),
        //       showNotificationId: 128,
        //       title: "(Foreground) ${message.notification?.title}",
        //       body: message.notification?.body ?? "You received a notification",
        //       payload: message.data['body'].toString() ?? "service",
        //     );
        final String routeFromNotification = message.data["route"].toString();

        if (routeFromNotification.isNotEmpty) {
          if (routeFromNotification == "service_screen") {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return RingScreen(payload: message.data["payload"].toString());
              },
            ));
          } else if (routeFromNotification == "order_screen") {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return OrderScreen(payload: message.data["payload"].toString());
              },
            ));
          }
        } else {
          print('could not find the route');
        }
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      Fluttertoast.showToast(
        msg: 'Just received a notification when app is opened',
      );

      // showNotification(message, context);
      if (message.notification != null) {
        final String routeFromNotification = message.data["route"].toString();
        if (routeFromNotification.isNotEmpty) {
          if (routeFromNotification == "service_screen") {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return RingScreen(payload: message.data["payload"].toString());
              },
            ));
          } else if (routeFromNotification == "order_screen") {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return OrderScreen(payload: message.data["payload"].toString());
              },
            ));
          }
        } else {
          print('could not find the route');
        }
      }
    });

    super.initState();
  }

  @pragma('vm:entry-point')
  @override
  Future<void> didChangeDependencies() async {
    await requestNotificationPermission();
    await context.read<NotificationService>().initialize(context);
    //TODO:Need to check
    await FirebaseMessageService().generateFirebaseMessageToken();
    final lastNotification =
        await FirebaseMessaging.instance.getInitialMessage();

    if (lastNotification != null) {
      if (lastNotification.data["route"].toString() == "service_screen") {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return RingScreen(
                payload: lastNotification.data["payload"].toString());
          },
        ));
      } else if (lastNotification.data["route"].toString() == "order_screen") {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return OrderScreen(
                payload: lastNotification.data["payload"].toString());
          },
        ));
      }
    }

    final userName = await CustomSharedPreference()
        .getData(key: SharedPreferenceKeys.userName);

    if (userName != null) {
      userNameTextController.text = userName.trim();
    }

    //Start the service automatically if it was activated before closing the application
    if (await BackgroundService().instance.isRunning()) {
      // await BackgroundService().instance.startService();
      await BackgroundService().initializeService();
    }
    BackgroundService()
        .instance
        .on('on_location_changed')
        .listen((event) async {
      if (event != null) {
        final position = Position(
          longitude: double.tryParse(event['longitude'].toString()) ?? 0.0,
          latitude: double.tryParse(event['latitude'].toString()) ?? 0.0,
          timestamp: DateTime.fromMillisecondsSinceEpoch(
              event['timestamp'].toInt(),
              isUtc: true),
          accuracy: double.tryParse(event['accuracy'].toString()) ?? 0.0,
          altitude: double.tryParse(event['altitude'].toString()) ?? 0.0,
          heading: double.tryParse(event['heading'].toString()) ?? 0.0,
          speed: double.tryParse(event['speed'].toString()) ?? 0.0,
          speedAccuracy:
              double.tryParse(event['speed_accuracy'].toString()) ?? 0.0,
        );

        await context
            .read<LocationControllerCubit>()
            .onLocationChanged(location: position);
      }
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Column(
        children: [
          Form(
            key: formkey,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 10,
              ),
              child: CustomTextFormField(
                controller: userNameTextController,
                label: "Enter your name",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Field can't be empty";
                  } else {
                    return null;
                  }
                },
                suffixIcon: IconButton(
                  onPressed: () {
                    userNameTextController.clear();
                  },
                  icon: const Icon(Icons.cancel),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          BlocBuilder<LocationControllerCubit, LocationControllerState>(
            builder: (context, state) {
              if (state is LocationFetched) {
                return Center(
                  child: Column(
                    children: [
                      Text(
                        "Latitude:${state.location.latitude}",
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        "Longitude:${state.location.longitude}",
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        "Altitude:${(state.location.altitude).toStringAsFixed(2)} m",
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        "Speed:${((state.location.speed) / 1000).toStringAsFixed(2)} KMPH",
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          BackgroundService().stopService();
                          await context
                              .read<LocationControllerCubit>()
                              .stopLocationFetch();
                        },
                        child: const Text("Stop sending"),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          context.read<NotificationService>().showNotification(
                                androidNotificationDetails:
                                    const AndroidNotificationDetails(
                                  "route",
                                  "route",
                                ),
                                title: "Navigation",
                                body:
                                    "Click here to open application and navigate to new screen.",
                                payload: "service",
                              );
                        },
                        child: const Text("show notification"),
                      ),
                    ],
                  ),
                );
              } else if (state is LoadingLocation) {
                return const Text(
                  "Loading your service...",
                  style: TextStyle(fontSize: 18),
                );
              } else {
                return ElevatedButton(
                  onPressed: () async {
                    if (formkey.currentState!.validate()) {
                      final permission = await context
                          .read<LocationControllerCubit>()
                          .enableGPSWithPermission();

                      if (permission) {
                        FocusScope.of(context).unfocus();
                        await CustomSharedPreference().storeData(
                          key: SharedPreferenceKeys.userName,
                          data: userNameTextController.text.trim(),
                        );
                        await context
                            .read<LocationControllerCubit>()
                            .locationFetchByDeviceGPS();
                        //Configure the service notification channel and start the service
                        await BackgroundService().initializeService();
                        //Set service as foreground.(Notification will available till the service end)
                        BackgroundService().setServiceAsForeGround();
                      }
                    }
                  },
                  child: const Text("Start data sending"),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
