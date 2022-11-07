// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:background_location_sender/background_service.dart';
import 'package:background_location_sender/firebase_messaging_service/service/firebase_message_service.dart';
import 'package:background_location_sender/home/logic/cubit/update_location_on_db_cubit.dart';
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
  late BackgroundService backgroundService;

  @pragma('vm:entry-point')
  @override
  Future<void> didChangeDependencies() async {
    backgroundService = BackgroundService();
    FirebaseMessageService().generateFirebaseMessageToken();
    await backgroundService.initializeService();
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.always &&
        await backgroundService.instance.isRunning()) {
      Geolocator.getPositionStream().listen(
        (Position currentLocation) async {
          await context.read<LocationControllerCubit>().onLocationChanged(
                updateLocationOnDbCubit:
                    context.read<UpdateLocationOnDbCubit>(),
                longitude: currentLocation.longitude,
                latitude: currentLocation.latitude,
              );
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const Text(
            //   "Your current location",
            //   style: TextStyle(fontSize: 16),
            // ),
            BlocBuilder<LocationControllerCubit, LocationControllerState>(
              builder: (context, state) {
                if (state is LocationFetched) {
                  return Center(
                    child: Column(
                      children: [
                        // Text(
                        //   "Latitude:${state.location.latitude}",
                        //   style: const TextStyle(fontSize: 20),
                        // ),
                        // Text(
                        //   "Longitude:${state.location.longitude}",
                        //   style: const TextStyle(fontSize: 20),
                        // ),
                        ElevatedButton(
                          onPressed: () {
                            backgroundService.stopService();
                            context
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
                      backgroundService.startService();
                      context
                          .read<LocationControllerCubit>()
                          .locationFetchByDeviceGPS();
                    },
                    child: const Text("Start data sending"),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
