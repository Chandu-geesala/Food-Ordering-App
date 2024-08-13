import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:user_app/view/mainScreens/orderDisplay.dart';
import 'cart_model.dart';
import 'package:flutter/material.dart';
import 'package:user_app/view/mainScreens/home_screen.dart';
import 'order_view_model.dart';// Make sure you have imported the HomeScreen file

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String address;
  final Map<String, int> menuItemsWithQuantity; // Updated parameter
  final String name;
  final String phone;
  final String sellerUid;

  PaymentScreen({
    required this.amount,
    required this.address,
    required this.menuItemsWithQuantity, // Initialize it
    required this.name,
    required this.phone,
    required this.sellerUid,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? selectedPaymentMethod;
  final OrderViewModel orderViewModel = OrderViewModel();



  Future<void> handlePayment() async {
    try {
      await orderViewModel.saveOrder(
        widget.menuItemsWithQuantity, // Pass quantities
        widget.amount,
        widget.name,
        widget.phone,
        widget.address,
        selectedPaymentMethod!,
        widget.sellerUid,
      );

      // Show Lottie animation for 4 seconds
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissal during animation
        builder: (BuildContext context) {
          return Center(
            child: Lottie.asset(
              'slider/tc.json', // Replace with your Lottie file path
              repeat: false,
            ),
          );
        },
      );

      await Future.delayed(Duration(seconds: 4));
      Navigator.of(context).pop(); // Close the Lottie animation dialog

      // Show success message
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Payment Successful'),
          content: Text(
              'Your payment using $selectedPaymentMethod of ₹${widget.amount.toStringAsFixed(2)} was successful!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Provider.of<CartProvider>(context, listen: false).clear();
                Navigator.push(context, MaterialPageRoute(builder: (c) => OrderDisplayPage()));
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Handle error
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Payment Failed'),
          content: Text('An error occurred: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,





          children: [
            Text(
              'Total Amount: ₹${widget.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Delivery Address:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Name: ${widget.name}',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            Text(
              'Phone: ${widget.phone}',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            Text(
              widget.address,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 32.0),
            Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            RadioListTile<String>(
              title: Text('Pay on Delivery'),
              value: 'Pay on Delivery',
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('UPI'),
              value: 'UPI',
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('WhatsApp Pay'),
              value: 'WhatsApp Pay',
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value;
                });
              },
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: selectedPaymentMethod == null
                    ? null
                    : () async {
                  await handlePayment();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text('Pay Now'),
              ),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
