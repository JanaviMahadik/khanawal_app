import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_item.dart';

class CartManager {
  static const _cartKeyPrefix = 'cart_items_';
  static List<CartItem> cartItems = [];

  static Future<String?> getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  static Future<void> loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await getUserId();
    if (userId == null) return;

    final cartItemsJson = prefs.getString(_cartKeyPrefix + userId);

    if (cartItemsJson != null) {
      final List<dynamic> cartItemsList = jsonDecode(cartItemsJson);
      cartItems = cartItemsList.map((json) => CartItem.fromJson(json)).toList();
    }
  }

  static Future<void> saveCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await getUserId();
    if (userId == null) return;

    final cartItemsJson = jsonEncode(cartItems.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKeyPrefix + userId, cartItemsJson);
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
