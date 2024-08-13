import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderViewModel {
  Future<void> saveOrder(
      Map<String, int> menuItemsWithQuantity, // Updated parameter
      double totalPrice,
      String name,
      String phone,
      String address,
      String paymentMethod,
      String sellerUid,
      ) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("No user is currently signed in.");
    }

    await FirebaseFirestore.instance.collection('orders').add({
      'userId': currentUser.uid,
      'menuItemsWithQuantity': menuItemsWithQuantity, // Store menu items with quantity
      'totalPrice': totalPrice,
      'name': name,
      'phone': phone,
      'address': address,
      'paymentMethod': paymentMethod,
      'sellerUid': sellerUid,
      'status': 'normal',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
