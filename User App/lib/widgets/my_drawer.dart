import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:user_app/global/global_instances.dart';
import 'package:user_app/global/global_vars.dart';
import 'package:user_app/view/mainScreens/home_screen.dart';
import 'package:user_app/view/splashScreen/splash_screen.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the user's name and extract the first letter in capital
    String userName = sharedPreferences!.getString("name") ?? "User";

    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "U";

    return Drawer(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75, // Adjust drawer width
        child: Column(
          children: [
            // Header Section
            Container(
              color: Colors.blueAccent,
              padding: const EdgeInsets.only(top: 40.0, bottom: 20.0, left: 16.0, right: 16.0), // Adjust top padding
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.grey),
            // Drawer Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _createDrawerItem(
                    icon: Icons.home,
                    text: "Home",
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                  ),
                  _createDrawerItem(
                    icon: Icons.search,
                    text: "Search",
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                  ),
                  _createDrawerItem(
                    icon: Icons.reorder,
                    text: "My Orders",
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                  ),
                  _createDrawerItem(
                    icon: Icons.local_shipping,
                    text: "History - Orders",

                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                  ),

                  _createDrawerItem(
                    icon: Icons.share_location,
                    text: "Update My Address",
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      commonViewModel.updateLocationInDatabase();
                      commonViewModel.showSnackBar("Location Updated Successfully", context);
                    },
                  ),

                  _createDrawerItem(
                    icon: Icons.exit_to_app,
                    text: "Sign Out",
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MysplashScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createDrawerItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      tileColor: Colors.white.withOpacity(0.05), // Subtle background color for each item
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
