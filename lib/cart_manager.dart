import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_item.dart';

class CartManager {
  static const _cartKey = 'cart_items';
  static List<CartItem> cartItems = [];

  static Future<void> loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartItemsJson = prefs.getString(_cartKey);

    if (cartItemsJson != null) {
      final List<dynamic> cartItemsList = jsonDecode(cartItemsJson);
      cartItems = cartItemsList.map((json) => CartItem.fromJson(json)).toList();
    }
  }

  static Future<void> saveCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartItemsJson = jsonEncode(cartItems.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKey, cartItemsJson);
  }

  static Future<void> addItem(CartItem item) async {
    cartItems.add(item);
    await saveCartItems();
  }

  static Future<void> removeItem(CartItem item) async {
    cartItems.remove(item);
    await saveCartItems();
  }

  static void clearCart() {
    cartItems.clear();
  }

}
