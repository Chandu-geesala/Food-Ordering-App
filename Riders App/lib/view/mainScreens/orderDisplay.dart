import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../viewModel/mapsUtils.dart';

class OrderDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Display'),
        backgroundColor: Colors.white,
      ),
      body: OrderList(),
    );
  }
}

class OrderList extends StatelessWidget {
  // Fetch details for a specific menu item
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

  // Fetch details for a specific seller
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
      // Get rider details from sharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? riderUid = prefs.getString('uid');
      final String? riderName = prefs.getString('name');
      final String? riderPhone = prefs.getString('phone');

      if (riderUid == null || riderName == null || riderPhone == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rider details are not available.')),
        );
        return;
      }

      // Update the order with the rider's details
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'riderUid': riderUid,
        'riderName': riderName,
        'riderPhone': riderPhone,
      });

      Navigator.pop(context); // Close the bottom sheet after confirming
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order confirmed and rider details added!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm order: $error')),
      );
    }
  }

  void showOrderDetails(BuildContext context, Map<String, dynamic> order, Map<String, dynamic> sellerDetails, String orderId) async {
    final sellerAddress = sellerDetails['address'] ?? 'Unknown Address';
    final userLat = order['userLat'];
    final userLng = order['userLng'];
    final sellerLat = sellerDetails['latitude'];
    final sellerLng = sellerDetails['longitude'];


    // Fetch menu items for this order along with their quantities
    List<Map<String, dynamic>> menuItems = [];
    double totalPrice = 0;

    for (String menuId in order['menuItemsWithQuantity'].keys) {
      var menuItem = await getMenuItemDetails(order['sellerUid'], menuId);
      if (menuItem.isNotEmpty) {
        menuItem['quantity'] = order['menuItemsWithQuantity'][menuId];
        menuItems.add(menuItem);

        // Calculate total price
        final itemPrice = menuItem['price'] ?? 0;
        totalPrice += itemPrice * menuItem['quantity'];
      }
    }

    void launchMapsAndUpdateStatusToPicking() async {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      try {
        Future<Position> positionFuture = Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        Position riderPosition = await positionFuture;

        double riderLat = riderPosition.latitude;
        double riderLng = riderPosition.longitude;
        MapUtils.lauchMapFromSourceToDestination(riderLat, riderLng, sellerLat, sellerLng);
      } catch (e) {
        print('Error launching map: $e');
      } finally {
        Navigator.of(context).pop();
      }
    }

    void launchMapsAndUpdateStatusToDelivering() async {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      try {
        String userId = order['userId'];
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        final userLat = userDoc['latitude'];
        final userLng = userDoc['longitude'];

        Position riderPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        double riderLat = riderPosition.latitude;
        double riderLng = riderPosition.longitude;

        MapUtils.lauchMapFromSourceToDestination(riderLat, riderLng, userLat, userLng);
      } catch (e) {
        print('Error updating status or launching map: $e');
      } finally {
        Navigator.of(context).pop();
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
                  child: Text('Confirm Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 10),


                Text('From:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),

                GestureDetector(
                  onTap: () {
                    launchMapsAndUpdateStatusToPicking();
                  },
                  child: Card(
                    color: Colors.pink,
                    child: ListTile(
                      title: Text(
                        sellerDetails['name'] ?? 'Unknown Seller',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(sellerDetails['address'] ?? 'Unknown Address'),
                    ),
                  ),
                ),




                SizedBox(height: 10),
                Text('To:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),


                GestureDetector(
                  onTap: () {
                    launchMapsAndUpdateStatusToDelivering();
                  },
                  child: Card(
                    color: Colors.green,
                    child: ListTile(
                      title: Text(
                        order['name'] ?? 'Unknown Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${order['address'] ?? 'Unknown Address'}\n${order['phone'] ?? 'Unknown Phone'}',
                      ),
                    ),
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
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper function to hide the last 5 characters
  String hideLastFiveChars(String input) {
    if (input.length <= 5) {
      return '*****'; // Or any placeholder text
    }
    return input.substring(0, input.length - 5) + '';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
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

        // Filter orders with status 'ready' and no rider allocated
        final orders = snapshot.data!.docs.where((doc) {
          final order = doc.data() as Map<String, dynamic>;
          return order['status'] == 'ready' && order['riderUid'] == null;
        }).toList();

        if (orders.isEmpty) {
          return Center(child: Text('No ready orders with unallocated riders found.'));
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index].data() as Map<String, dynamic>;
            final sellerUid = order['sellerUid'] as String?;
            final orderId = orders[index].id; // Use the document ID as the order ID

            // Format the order ID
            final formattedOrderId = hideLastFiveChars(orderId);

            return FutureBuilder<Map<String, dynamic>>(
              future: sellerUid != null ? getSellerDetails(sellerUid) : Future.value({}),
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
                    title: Text('Order ID: $formattedOrderId'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${order['status'] ?? 'Unknown Status'}'),
                        Text('Seller: ${sellerDetails['name'] ?? 'Unknown Seller'}\nAddress: ${order['address'] ?? 'Unknown Address'}'),
                        Text('Total Price: \₹${order['totalPrice'].toStringAsFixed(2)}'),
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
  }
}
