import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gym_app_flutter/features/Auth/sign_in_page.dart';
import 'package:gym_app_flutter/features/home/view/home_screeen.dart';
import 'package:gym_app_flutter/features/workout/view/camera_streaming.dart';
import 'package:gym_app_flutter/features/workout/view/workout_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';

import 'features/Auth/wrapper.dart';

late List<CameraDescription> cameras;
void  main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const Wrapper(), // 👈 Launch HomeScreen on app start
    );
  }
}
