import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/viewModel/cart_model.dart';
import 'selectAddress.dart';
import 'paymentScreen.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Map<String, String>? selectedAddressDetails;

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Colors.white70,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Cart',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, i) => CartItemWidget(
                    id: cart.items.values.toList()[i].id,
                    title: cart.items.values.toList()[i].title,
                    quantity: cart.items.values.toList()[i].quantity,
                    price: cart.items.values.toList()[i].price,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Total: ₹${cart.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              if (selectedAddressDetails != null) ...[
                SizedBox(height: 16.0),
                Text(
                  'Selected Address:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                Text(
                  'Name: ${selectedAddressDetails!['name']}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Text(
                  'Phone: ${selectedAddressDetails!['phone']}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Text(
                  'Address: ${selectedAddressDetails!['address']}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
              SizedBox(height: 16.0),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final selected = await Navigator.push<Map<String, String>>(
                          context,
                          MaterialPageRoute(builder: (context) => SelectAddressScreen()),
                        );
                        if (selected != null) {
                          setState(() {
                            selectedAddressDetails = selected;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(selectedAddressDetails == null ? 'Select Address' : 'Change Address'),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: selectedAddressDetails == null
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                              amount: cart.totalAmount,
                              address: selectedAddressDetails!['address']!,
                              menuItemsWithQuantity: cart.items.map((key, item) => MapEntry(item.id, item.quantity)), // Pass quantities
                              name: selectedAddressDetails!['name']!,
                              phone: selectedAddressDetails!['phone']!,
                              sellerUid: cart.currentSellerId!, // Pass sellerUid
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text('Proceed to Pay'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItemWidget({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {


    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.black.withOpacity(0.5), width: 1.0), // Adjust color and width as needed
        borderRadius: BorderRadius.circular(8.0), // Adjust the radius if needed
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(title, style: TextStyle(fontSize: 18)),
          subtitle: Text('Total: ₹${(price * quantity).toStringAsFixed(2)}'),
          trailing: Text('$quantity x ₹${price.toStringAsFixed(2)}', style: TextStyle(fontSize: 14)),
        ),
      ),
    );



  }
}
