// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:background_location_sender/firebase_messaging_service/service/firebase_message_service.dart';
import 'package:background_location_sender/home/logic/cubit/update_location_on_db_cubit.dart';
import 'package:background_location_sender/location_service/logic/location_controller/location_controller_cubit.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Future<void> didChangeDependencies() async {
    FirebaseMessageService().generateFirebaseMessageToken();

    Location location = Location();
    location.onLocationChanged.listen((LocationData currentLocation) {
      context.read<LocationControllerCubit>().onLocationChanged(
            updateLocationOnDbCubit: context.read<UpdateLocationOnDbCubit>(),
            longitude: currentLocation.longitude ?? 0,
            latitude: currentLocation.latitude ?? 0,
          );
    });
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
            const Text(
              "Your current location",
              style: TextStyle(fontSize: 16),
            ),
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
                      ],
                    ),
                  );
                } else if (state is LoadingLocation) {
                  return const Text(
                    "Loading your location...",
                    style: TextStyle(fontSize: 18),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
