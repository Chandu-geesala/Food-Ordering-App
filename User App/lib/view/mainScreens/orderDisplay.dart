import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderDisplayPage extends StatefulWidget {
  @override
  _OrderDisplayPageState createState() => _OrderDisplayPageState();
}

class _OrderDisplayPageState extends State<OrderDisplayPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  Stream<List<Map<String, dynamic>>> fetchOrdersStream() {
    if (currentUser == null) {
      throw Exception("No user is currently signed in.");
    }

    return FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: currentUser!.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Add the document ID to the data
      return data;
    }).toList());
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

  void showOrderDetails(Map<String, dynamic> order, String sellerName) async {
    List<Map<String, dynamic>> menuItems = [];

    // Fetching details for each menu item in the order
    for (String menuId in order['menuItemsWithQuantity'].keys) {
      var menuItem = await getMenuItemDetails(order['sellerUid'], menuId);
      if (menuItem.isNotEmpty) {
        menuItem['quantity'] = order['menuItemsWithQuantity'][menuId]; // Add quantity to the item
        menuItems.add(menuItem);
      }
    }

    // Extract the last 5 characters of the orderId
    String orderId = order['id'] ?? '';
    String pinCode = orderId.length >= 5 ? orderId.substring(orderId.length - 5) : 'N/A';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'PIN: $pinCode',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Seller: $sellerName',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Rider Phone: ${order['riderPhone'] ?? 'Not assigned'}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    _buildOrderTracking(order['status']),
                    SizedBox(height: 20),
                    Text(
                      'Ordered Items:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    SizedBox(height: 20),
                    Text(
                      'Total Price: \₹${order['totalPrice'].toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderTracking(String status) {
    final stages = [
      {
        'label': 'Placed',
        'icon': Icons.receipt,
        'isActive': status == 'normal' || status == 'ready' || status == 'picked' || status == 'delivered'
      },
      {
        'label': 'Ready',
        'icon': Icons.dinner_dining,
        'isActive': status == 'ready' || status == 'picked' || status == 'delivered'
      },
      {
        'label': 'Picked',
        'icon': Icons.store,
        'isActive': status == 'picked' || status == 'delivered'
      },
      {
        'label': 'Delivered',
        'icon': Icons.check_circle_outline,
        'isActive': status == 'delivered'
      },
    ];

    return Column(
      children: stages.map((stage) {
        return _buildTrackingStep(
          label: stage['label'] as String,
          icon: stage['icon'] as IconData,
          isActive: stage['isActive'] as bool,
        );
      }).toList(),
    );
  }

  Widget _buildTrackingStep({required String label, required IconData icon, required bool isActive}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, color: isActive ? Colors.green : Colors.grey, size: 30),
            if (label != 'On the Way to You') ...[
              Container(
                width: 2,
                height: 50,
                color: isActive ? Colors.green : Colors.grey,
              ),
            ],
          ],
        ),
        SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.green : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fetchOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No orders found.'));
          }

          List<Map<String, dynamic>> orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> order = orders[index];
              String sellerName = order['sellerName'] ?? 'Unknown Seller';

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text('Order: ${order['timestamp'].toDate().toString()}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Seller: $sellerName'),
                      Text('Total Price: \₹${order['totalPrice'].toStringAsFixed(2)}'),
                      ...order['menuItemsWithQuantity'].entries.map((entry) {
                        return FutureBuilder<Map<String, dynamic>>(
                          future: getMenuItemDetails(order['sellerUid'], entry.key),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return Container();
                            var item = snapshot.data!;
                            return Row(
                              children: [
                                if (item['menuImage'] != null)
                                  Image.network(item['menuImage'], width: 40, height: 40, fit: BoxFit.cover),
                                SizedBox(width: 10),
                                Text('${item['menuTitle'] ?? 'Unknown Item'} (x${entry.value})'),
                              ],
                            );
                          },
                        );
                      }).toList(),
                    ],
                  ),
                  onTap: () => showOrderDetails(order, sellerName),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
