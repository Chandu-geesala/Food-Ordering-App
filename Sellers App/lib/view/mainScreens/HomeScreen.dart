import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seller_app/view/mainScreens/NewOrders.dart';
import '../../global/global_vars.dart';
import '../../widgets/my_drawer.dart';
import 'CompletedOrders.dart';
import 'MyMenu.dart';
import 'ReadyOrders.dart';
import 'menuUploadScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String userName = sharedPreferences!.getString("name") ?? "User";

  bool isSellerAvailable = false;
  String? sellerUid;
  bool isLoading = true;

  void _onItemTapped(int index) {
    Widget nextPage;

    if (index == 0) {
      nextPage = HomeScreen();
    } else if (index == 1) {
      nextPage = MyMenu();
    } else {
      return; // Handle other cases if needed
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  void _onAddMenuPressed() {
    // Navigate to the Add New Menu screen.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MenuUploadScreen()),
    );
  }



  @override
  void initState() {
    super.initState();
    _loadSellerUidAndData();  // Load sellerUid from SharedPreferences and Firestore data
  }

  Future<void> _loadSellerUidAndData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      sellerUid = prefs.getString("uid");

      if (sellerUid != null) {
        print("Seller UID loaded: $sellerUid");

        // Fetch the seller's data from Firestore
        DocumentSnapshot sellerDoc = await FirebaseFirestore.instance
            .collection("sellers")
            .doc(sellerUid)
            .get();

        if (sellerDoc.exists) {
          print("Seller document exists, fetching availability...");
          setState(() {
            isSellerAvailable = sellerDoc['availability'] == 'yes';
            isLoading = false;  // Stop the loading spinner
          });
        } else {
          print("Seller document does not exist in Firestore.");
          setState(() {
            isLoading = false;  // Stop the loading spinner
          });
        }
      } else {
        print("Seller UID is null.");
        setState(() {
          isLoading = false;  // Stop the loading spinner
        });
      }
    } catch (e) {
      print("Failed to load seller data: $e");
      setState(() {
        isLoading = false;  // Stop the loading spinner even on error
      });
    }
  }

  Future<void> _updateAvailability(bool availability) async {
    if (sellerUid == null) {
      print("Seller UID is null");
      return;
    }

    String availabilityStatus = availability ? "yes" : "no";

    try {
      DocumentReference sellerDoc = FirebaseFirestore.instance
          .collection("sellers")
          .doc(sellerUid);

      // Update the availability status in Firestore
      await sellerDoc.update({
        "availability": availabilityStatus,
      });
      print("Availability updated to $availabilityStatus");
    } catch (e) {
      print("Failed to update availability: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        //backgroundColor: Colors.deepOrangeAccent, // Example color
        elevation: 8.0,
        backgroundColor: Colors.white,
        title: Row(
          children: [

            SizedBox(width: 10),
            Text(
              '$userName',
              style: TextStyle(color: Colors.black),
            ),

          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_outlined),
            color: Colors.black,
            onPressed: () {},
          ),
        ],
      ),
      drawer: MyDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'My Menu',
          ),
        ],
        selectedItemColor: Colors.orange,
        onTap: _onItemTapped,
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading spinner while fetching data
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Is Food Available?',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Text(
                  isSellerAvailable ? 'Yes' : 'No',
                  style: TextStyle(
                    color: isSellerAvailable ? Colors.green : Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: isSellerAvailable,
                  onChanged: (value) async {
                    setState(() {
                      isSellerAvailable = value;
                    });
                    await _updateAvailability(value); // Ensure this runs
                  },
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Quick Overview',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildStatusCard(
                    icon: Icons.assignment_turned_in,
                    title: 'New Orders',
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NewOrders()),
                      );
                    },
                  ),
                  _buildStatusCard(
                    icon: Icons.fastfood,
                    title: 'Ready Orders',
                    color: Colors.blue,
                    onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context) => ReadyOrders()),);
                    },
                  ),
                  _buildStatusCard(
                    icon: Icons.check_circle_outline,
                    title: 'Completed Orders',
                    color: Colors.orangeAccent,
                    onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context) => CompletedOrders()),);
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

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required Color color,
    Function()? onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 40),
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
