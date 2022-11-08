// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'dart:async';
import 'package:background_location_sender/home/widgets/custom_text_form_field.dart';
import 'package:background_location_sender/utility/shared_preference/shared_preference.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:background_location_sender/background_service.dart';
import 'package:background_location_sender/firebase_messaging_service/service/firebase_message_service.dart';
import 'package:background_location_sender/location_service/logic/location_controller/location_controller_cubit.dart';
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

  @pragma('vm:entry-point')
  @override
  Future<void> didChangeDependencies() async {
    await BackgroundService().initializeService();
    FirebaseMessageService().generateFirebaseMessageToken();

    final userName = await CustomSharedPreference()
        .getData(key: SharedPreferenceKeys.userName);

    if (userName != null) {
      userNameTextController.text = userName.trim();
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always) {
      Geolocator.getPositionStream().listen(
        (Position currentLocation) async {
          if (await BackgroundService().instance.isRunning()) {
            await context
                .read<LocationControllerCubit>()
                .onLocationChanged(location: currentLocation);
          }
        },
      );
    } else if (permission == LocationPermission.denied) {
      context.read<LocationControllerCubit>().locationFetchByDeviceGPS();
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
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
                      FocusScope.of(context).unfocus();
                      await CustomSharedPreference().storeData(
                        key: SharedPreferenceKeys.userName,
                        data: userNameTextController.text.trim(),
                      );
                      await BackgroundService().startService();
                      await context
                          .read<LocationControllerCubit>()
                          .locationFetchByDeviceGPS();
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
