import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/viewModel/cart_model.dart';
import 'package:user_app/viewModel/checkout.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class MenuDisplayScreen extends StatelessWidget {
  final String sellerUid;

  MenuDisplayScreen({required this.sellerUid});

  void prefetchImages(BuildContext context, List<String> imageUrls) {
    for (String url in imageUrls) {
      precacheImage(NetworkImage(url), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Menu'),
        backgroundColor: Colors.white70,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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

                // Optionally, prefetch images here if desired
                prefetchImages(context, menuItems.map((item) => item['menuImage'].toString()).toList());

                return LazyLoadScrollView(
                  onEndOfPage: () {
                    // Load more data if necessary
                  },
                  child: ListView.builder(
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      var item = menuItems[index];
                      return MenuCard(item: item, sellerUid: sellerUid);
                    },
                  ),
                );
              },
            ),
          ),
          if (cart.itemCount > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white60,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Items: ${cart.totalQuantity}  Total: ₹${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CheckoutScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final QueryDocumentSnapshot item;
  final String sellerUid;

  MenuCard({required this.item, required this.sellerUid});

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartProvider>(context);
    int quantity = cart.getItemQuantity(item['menuId']);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Card(
        color: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              item['menuImage'] != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: CachedNetworkImage(
                  imageUrl: item['menuImage'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
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
              SizedBox(height: 10.0),
              Align(
                alignment: Alignment.centerRight,
                child: QuantityControl(
                  itemId: item['menuId'],
                  initialQuantity: quantity,
                  price: double.parse(item['menuPrice']),
                  title: item['menuTitle'],
                  sellerId: sellerUid,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class QuantityControl extends StatefulWidget {
  final String itemId;
  final int initialQuantity;
  final double price;
  final String title;
  final String sellerId;

  QuantityControl({
    required this.itemId,
    required this.initialQuantity,
    required this.price,
    required this.title,
    required this.sellerId,
  });

  @override
  _QuantityControlState createState() => _QuantityControlState();
}

class _QuantityControlState extends State<QuantityControl> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
  }

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartProvider>(context);

    return quantity == 0
        ? ElevatedButton(
      onPressed: () {
        if (cart.currentSellerId != null && cart.currentSellerId != widget.sellerId) {
          _showReplaceCartDialog(context, cart);
        } else {
          setState(() {
            quantity++;
          });
          cart.addItem(widget.itemId, widget.price, widget.title, widget.sellerId);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        textStyle: TextStyle(fontSize: 16.0),
      ),
      child: Text("ADD"),
    )
        : Container(
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(20.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove, color: Colors.white),
            onPressed: () {
              setState(() {
                if (quantity > 0) quantity--;
              });
              cart.removeSingleItem(widget.itemId);
            },
          ),
          Text(
            quantity.toString(),
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              setState(() {
                quantity++;
              });
              cart.addItem(widget.itemId, widget.price, widget.title, widget.sellerId);
            },
          ),
        ],
      ),
    );
  }

  void _showReplaceCartDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Replace Cart'),
        content: Text('You already have items from another seller in your cart. Do you want to replace them?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cart.clear();
              setState(() {
                quantity++;
              });
              cart.addItem(widget.itemId, widget.price, widget.title, widget.sellerId);
              Navigator.of(ctx).pop();
            },
            child: Text('Replace'),
          ),
        ],
      ),
    );
  }
}
