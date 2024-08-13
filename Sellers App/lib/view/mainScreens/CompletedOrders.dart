import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seller_app/view/mainScreens/MyMenu.dart';
import 'package:seller_app/view/mainScreens/menuUploadScreen.dart';
import '../../widgets/my_drawer.dart';

class CompletedOrders extends StatefulWidget {
  @override
  _CompletedOrdersState createState() => _CompletedOrdersState();
}

class _CompletedOrdersState extends State<CompletedOrders> {
  void _onItemTapped(int index) {
    Widget nextPage;

    if (index == 0) {
      nextPage = OrderList();
    } else if (index == 1) {
      nextPage = MyMenu();
    } else {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  void _onAddMenuPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MenuUploadScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Orders'),
      ),
      drawer: MyDrawer(),
      body: OrderList(),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            label: 'New Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'My Menu',
          ),
        ],
        selectedItemColor: Colors.orange,
        onTap: _onItemTapped,
      ),

    );
  }
}

class OrderList extends StatelessWidget {
  Future<String?> getSellerUidFromPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('uid');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getSellerUidFromPreferences(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('Failed to retrieve seller UID.'));
        }

        String? sellerUid = snapshot.data;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('status', isEqualTo: 'picked')
              .where('sellerUid', isEqualTo: sellerUid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No orders found.'));
            }

            final orders = snapshot.data!.docs;

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index].data() as Map<String, dynamic>;
                final orderId = orders[index].id;

                return FutureBuilder<Map<String, dynamic>>(
                  future: getSellerDetails(sellerUid!),
                  builder: (context, sellerDetailsSnapshot) {
                    if (sellerDetailsSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (sellerDetailsSnapshot.hasError) {
                      return Center(child: Text('Error: ${sellerDetailsSnapshot.error}'));
                    }
                    final sellerDetails = sellerDetailsSnapshot.data ?? {};

                    return Card(
                      color: Colors.white,
                      margin: EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      child: ListTile(
                        title: Text('Order ID: $orderId'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status: ${order['status'] ?? 'Unknown Status'}'),
                            Text('Seller: ${sellerDetails['name'] ?? 'Unknown Seller'}'),
                            Text('Total Price: \₹${order['totalPrice'].toStringAsFixed(2)}'),
                            Text('Address: ${order['address'] ?? 'Unknown Address'}'),
                          ],
                        ),
                        onTap: () => showOrderDetails(context, order, sellerDetails, orderId),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> getSellerDetails(String sellerUid) async {
    try {
      final sellerDoc = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(sellerUid)
          .get();
      return sellerDoc.data() ?? {};
    } catch (e) {
      print('Error retrieving seller details for UID $sellerUid: $e');
      return {};
    }
  }

  void confirmOrder(BuildContext context, String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': 'ready',
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order Ready')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm order: $error')),
      );
    }
  }

  void showOrderDetails(BuildContext context, Map<String, dynamic> order, Map<String, dynamic> sellerDetails, String orderId) async {
    final sellerAddress = sellerDetails['address'] ?? 'Unknown Address';

    // Fetch menu items for this order along with their quantities
    List<Map<String, dynamic>> menuItems = [];
    for (String menuId in order['menuItemsWithQuantity'].keys) {
      var menuItem = await getMenuItemDetails(order['sellerUid'], menuId);
      if (menuItem.isNotEmpty) {
        menuItem['quantity'] = order['menuItemsWithQuantity'][menuId]; // Add quantity to the item
        menuItems.add(menuItem);
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => confirmOrder(context, orderId),
                  child: Text('Order Ready'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                    textStyle: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                SizedBox(height: 10),
                Text('Items:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                ...menuItems.map((item) {
                  return ListTile(
                    leading: item['menuImage'] != null
                        ? Image.network(item['menuImage'], width: 50, height: 50, fit: BoxFit.cover)
                        : Icon(Icons.fastfood, size: 50),
                    title: Text(item['menuTitle'] ?? 'Unknown Item'),
                    subtitle: Text(
                      'Quantity: ${item['quantity']} \n${item['menuDescription'] ?? 'No description available'}',
                    ),
                  );
                }).toList(),
                SizedBox(height: 10),
                Text(
                  'Total Price: \₹${order['totalPrice'].toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(height: 10),
                Text('From:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                Card(
                  color: Colors.pink,
                  child: ListTile(
                    title: Text(sellerDetails['name'] ?? 'Unknown Seller', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(sellerAddress),
                  ),
                ),
                SizedBox(height: 10),
                Text('To:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                Card(
                  color: Colors.green,
                  child: ListTile(
                    title: Text(order['name'] ?? 'Unknown Name', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${order['address'] ?? 'Unknown Address'}\n${order['phone'] ?? 'Unknown Phone'}'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> getMenuItemDetails(String sellerUid, String menuId) async {
    try {
      final menuItemDoc = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(sellerUid)
          .collection('menus')
          .doc(menuId)
          .get();
      return menuItemDoc.data() ?? {};
    } catch (e) {
      print('Error retrieving menu item details for ID $menuId: $e');
      return {};
    }
  }
}
