import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;
  final String sellerId;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
    required this.sellerId,
  });
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  String? currentSellerId;

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  int get totalQuantity {
    var totalQuantity = 0;
    _items.forEach((key, cartItem) {
      totalQuantity += cartItem.quantity;
    });
    return totalQuantity;
  }

  int getItemQuantity(String itemId) {
    return _items.containsKey(itemId) ? _items[itemId]!.quantity : 0;
  }

  void addItem(String itemId, double price, String title, String sellerId) {
    if (currentSellerId != null && currentSellerId != sellerId) {
      return; // Prevent adding items from a different seller
    }
    if (_items.containsKey(itemId)) {
      _items.update(
        itemId,
            (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          quantity: existingCartItem.quantity + 1,
          price: existingCartItem.price,
          sellerId: existingCartItem.sellerId,
        ),
      );
    } else {
      _items.putIfAbsent(
        itemId,
            () => CartItem(
          id: itemId,
          title: title,
          quantity: 1,
          price: price,
          sellerId: sellerId,
        ),
      );
    }
    currentSellerId = sellerId;
    notifyListeners();
  }

  void removeItem(String itemId) {
    _items.remove(itemId);
    if (_items.isEmpty) {
      currentSellerId = null;
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    currentSellerId = null;
    notifyListeners();
  }

  void removeSingleItem(String itemId) {
    if (!_items.containsKey(itemId)) {
      return;
    }
    if (_items[itemId]!.quantity > 1) {
      _items.update(
        itemId,
            (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          quantity: existingCartItem.quantity - 1,
          price: existingCartItem.price,
          sellerId: existingCartItem.sellerId,
        ),
      );
    } else {
      _items.remove(itemId);
      if (_items.isEmpty) {
        currentSellerId = null;
      }
    }
    notifyListeners();
  }
}
