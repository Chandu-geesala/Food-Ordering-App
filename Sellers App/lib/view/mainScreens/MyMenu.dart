import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HomeScreen.dart';
import 'edit_menu_items.dart';
import 'package:seller_app/widgets/my_drawer.dart';

import 'menuUploadScreen.dart';

class MyMenu extends StatefulWidget {
  @override
  _MyMenuState createState() => _MyMenuState();
}

class _MyMenuState extends State<MyMenu> {
  final String sellerUid = FirebaseAuth.instance.currentUser!.uid;
  int _selectedIndex = 1; // Setting the initial selected index to 1 for "My Menu"

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });

    Widget nextPage;

    if (index == 0) {
      nextPage = HomeScreen();
    } else if (index == 1) {
      nextPage = MyMenu(); // Re-select "My Menu", no need to navigate
    } else {
      return; // Handle other cases if needed
    }

    if (index != 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    }
  }

  void _onAddMenuPressed() {
    // Navigate to the Add New Menu screen.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MenuUploadScreen()),
    );
  }

  Future<void> _navigateToEditMenuItem(BuildContext context, String menuItemId, Map<String, dynamic> menuItem) async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMenuItemScreen(menuItemId: menuItemId, menuItem: menuItem),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Menu Items'),
        backgroundColor: Colors.white60,
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
        currentIndex: _selectedIndex, // Setting the current index
        selectedItemColor: Colors.orange,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddMenuPressed,
        label: Text('Add Menu',style: TextStyle(color: Colors.black,fontSize: 18),),
        icon: Icon(Icons.add),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('sellers')
              .doc(sellerUid)
              .collection('menus')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var menuItems = snapshot.data!.docs;

            if (menuItems.isEmpty) {
              return Center(
                child: Text(
                  'No menu items found. Please add some!',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                var item = menuItems[index];
                return GestureDetector(
                  onTap: () => _navigateToEditMenuItem(context, item.id, item.data() as Map<String, dynamic>),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Card(
                      color: Colors.white,
                      elevation: 10, // Increased elevation for a more prominent shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      shadowColor: Colors.black.withOpacity(0.5), // Adjust shadow color opacity
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            item['menuImage'] != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: Stack(
                                children: [
                                  Center(child: CircularProgressIndicator()),
                                  Image.network(
                                    item['menuImage'],
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            )
                                : Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.black,
                              child: Icon(
                                Icons.fastfood,
                                color: Colors.black,
                                size: 100,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              item['menuTitle'],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              item['menuDescription'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              'Category: ${item['menuCategory']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              'Price: ₹${item['menuPrice']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
