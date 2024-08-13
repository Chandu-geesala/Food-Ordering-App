import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:user_app/view/auth_screens/auth_screen.dart';
import 'package:user_app/view/mainScreens/home_screen.dart';
import 'package:user_app/view/mainScreens/orderDisplay.dart';
import 'package:user_app/widgets/my_drawer.dart';



class MysplashScreen extends StatefulWidget {
  const MysplashScreen({super.key});

  @override
  State<MysplashScreen> createState() => _MysplashScreenState();
}

class _MysplashScreenState extends State<MysplashScreen>
{
  initTimer() {
    Timer(const Duration(seconds: 5), () async {
      if(FirebaseAuth.instance.currentUser== null){
        Navigator.push(context, MaterialPageRoute(builder: (c)=> LandingPage()));
      }else{
        Navigator.push(context, MaterialPageRoute(builder: (c)=> HomeScreen()));
      }
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
        child: Lottie.asset('videos/user.json'),
      ),
    );
  }
}
