import 'package:background_location_sender/firebase_options.dart';
import 'package:background_location_sender/home/logic/cubit/update_location_on_db_cubit.dart';
import 'package:background_location_sender/home/screens/home_screen.dart';
import 'package:background_location_sender/location_service/logic/location_controller/location_controller_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
