import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:seller_app/global/global_vars.dart';
import 'package:seller_app/viewModel/common_view_model.dart';
import 'package:seller_app/global/global_instances.dart';
import 'package:seller_app/viewModel/auth_view_model.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationTextEditingController = TextEditingController();
  bool isLoadingLocation = false;
  bool isLoadingSignUp = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(255, 138, 120, 1),
              Color.fromRGBO(255, 114, 117, 1),
              Color.fromRGBO(255, 63, 111, 1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formkey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    'Zombie',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'MuseoModerno',
                    ),
                  ),
                ),
                Text(
                  'Think. Click. Pick',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 17,
                    color: Color.fromRGBO(252, 188, 126, 1),
                  ),
                ),
                SizedBox(height: 60),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 50),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: Color.fromRGBO(255, 63, 111, 1),
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'User name',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                      icon: Icon(
                        Icons.account_circle,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 50),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: Color.fromRGBO(255, 63, 111, 1),
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Email',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                      icon: Icon(
                        Icons.email,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 50),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.number,
                    cursorColor: Color.fromRGBO(255, 63, 111, 1),
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Phone Number',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                      icon: Icon(
                        Icons.phone,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10), // Limiting to 10 digits
                    ],
                  ),

                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 50),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: TextFormField(
                    obscureText: true,
                    controller: passwordController,
                    cursorColor: Color.fromRGBO(255, 63, 111, 1),
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                      icon: Icon(
                        Icons.lock,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 50),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    cursorColor: Color.fromRGBO(255, 63, 111, 1),
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Confirm Password',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                      icon: Icon(
                        Icons.lock,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 50),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: TextFormField(
                    controller: locationTextEditingController,
                    cursorColor: Color.fromRGBO(255, 63, 111, 1),
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Restaurant Address',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                      icon: Icon(
                        Icons.my_location,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isLoadingLocation = true;
                    });
                    String address = await commonViewModel.getCurrentLocation();
                    setState(() {
                      locationTextEditingController.text = address;
                      isLoadingLocation = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: isLoadingLocation
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromRGBO(255, 63, 111, 1),
                    ),
                  )
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.location_on_outlined,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Get My Location',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 63, 111, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      isLoadingSignUp = true;
                    });
                    await authViewModel.validateSignUpForm(
                      passwordController.text.trim(),
                      confirmPasswordController.text.trim(),
                      nameController.text.trim(),
                      emailController.text.trim(),
                      phoneController.text.trim(),
                      locationTextEditingController.text.trim(),
                      context,
                    );
                    setState(() {
                      isLoadingSignUp = false;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: isLoadingSignUp
                        ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromRGBO(255, 63, 111, 1),
                      ),
                    )
                        : Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromRGBO(255, 63, 111, 1),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Already a registered user?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Log In here',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
