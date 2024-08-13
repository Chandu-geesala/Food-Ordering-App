import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riders_app/viewModel/mapsUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmedOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmed Orders'),
        backgroundColor: Colors.orange,
      ),
      body: OrderList(),
    );
  }
}

class OrderList extends StatelessWidget {
  Future<String?> getLoggedInRiderUid() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid'); // Fetch the logged-in rider's UID
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

  void showOrderDetails(BuildContext context, Map<String, dynamic> order, Map<String, dynamic> sellerDetails, String orderId) async {
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
                SizedBox(height: 10),



                Text(
                  'From:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),


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
                Text(
                  'To:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),


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
                Text(
                  'Items:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
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
    return FutureBuilder<String?>(
      future: getLoggedInRiderUid(), // Fetch the logged-in rider's UID
      builder: (context, riderUidSnapshot) {
        if (riderUidSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (riderUidSnapshot.hasError) {
          return Center(child: Text('Error: ${riderUidSnapshot.error}'));
        }
        if (!riderUidSnapshot.hasData) {
          return Center(child: Text('Rider UID not found.'));
        }

        final loggedInRiderUid = riderUidSnapshot.data!;

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

            final orders = snapshot.data!.docs.where((doc) {
              final order = doc.data() as Map<String, dynamic>;
              return order['status'] == 'ready' && order['riderUid'] == loggedInRiderUid;
            }).toList();

            if (orders.isEmpty) {
              return Center(child: Text('No confirmed orders found.'));
            }

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index].data() as Map<String, dynamic>;
                final sellerUid = order['sellerUid'] as String?;
                final orderId = orders[index].id;
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
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('Order ID: $formattedOrderId'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status: ${order['status'] ?? 'Unknown Status'}'),
                            Text(
                              'Seller: ${sellerDetails['name'] ?? 'Unknown Seller'}\nAddress: ${sellerDetails['address'] ?? 'Unknown Address'}',
                            ),
                            Text('Total Price: \₹${order['totalPrice'].toStringAsFixed(2)}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.info_outline),
                          onPressed: () => showOrderDetails(context, order, sellerDetails, orderId),
                        ),
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
}
