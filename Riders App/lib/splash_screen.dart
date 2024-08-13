import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MysplashScreen extends StatefulWidget {
  const MysplashScreen({super.key});

  @override
  State<MysplashScreen> createState() => _MysplashScreenState();
}

class _MysplashScreenState extends State<MysplashScreen> {
  void initTimer() {
    Timer(const Duration(seconds: 7), () async {
      // Add your navigation code here
      // Example: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NextScreen()));
    });
  }

  @override
  void initState() {
    super.initState();
    initTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset('images/anim2.json'),
      ),
    );
  }
}
