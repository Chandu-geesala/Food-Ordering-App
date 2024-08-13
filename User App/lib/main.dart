import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:user_app/view/splashScreen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:user_app/viewModel/cart_model.dart'; // Import your CartProvider

import 'global/global_vars.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid
      ? await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyD2f4HYSXPl664jXY02TftIsND4SxH8ViM",
          appId: "1:187850466874:android:38bb73902afd4521f2b703",
          messagingSenderId: "187850466874",
          projectId: 'minerva-1fdeb'))
      : await Firebase.initializeApp();

  sharedPreferences = await SharedPreferences.getInstance();

  await Permission.locationWhenInUse.isDenied.then((valueOfPermission) {
    if (valueOfPermission) {
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
    return ChangeNotifierProvider(
      create: (ctx) => CartProvider(),
      child: MaterialApp(

        debugShowCheckedModeBanner: false,
        home: const MysplashScreen(), // added const
      ),
    );
  }
}
