import 'package:background_location_sender/firebase_messaging_service/service/firebase_message_service.dart';
import 'package:background_location_sender/home/logic/cubit/update_location_on_db_cubit.dart';
import 'package:background_location_sender/location_service/logic/location_controller/location_controller_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    FirebaseMessageService().generateFirebaseMessageToken();
    print("PELA");
    context.read<LocationControllerCubit>().locationFetchByDeviceGPS();
    Location location = Location();

    location.onLocationChanged.listen((LocationData currentLocation) {
      print("BALA");
      context.read<LocationControllerCubit>().onLocationChanged(
          currentLocation: currentLocation,
          updateLocationOnDbCubit: context.read<UpdateLocationOnDbCubit>());
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Column(
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
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }
}
