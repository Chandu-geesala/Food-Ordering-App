import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riders_app/view/splashScreen/splash_screen.dart';
import 'package:riders_app/view/mainScreens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';


import 'global/global_vars.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid
      ? await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "API key",
          appId: "API ID",
          messagingSenderId: " ",
          projectId: 'ID' )
  )
      : await Firebase.initializeApp();



  sharedPreferences = await SharedPreferences.getInstance();






  await Permission.locationWhenInUse.isDenied.then((valueOfPermission){
    if(valueOfPermission){
      Permission.locationWhenInUse.request();
    }
  });



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(


      debugShowCheckedModeBanner: false,
      home: const MysplashScreen(), // added const
    );
  }
}




