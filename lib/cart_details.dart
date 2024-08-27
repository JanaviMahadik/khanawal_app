import 'package:flutter/material.dart';

import 'cook_home_page.dart';
import 'customer_home_page.dart';

class CartDetailsPage extends StatefulWidget {
  final List<Item> cartItems;

  const CartDetailsPage({Key? key, required this.cartItems}) : super(key: key);
  @override
  _CartDetailsPageState createState() => _CartDetailsPageState();
}

class _CartDetailsPageState extends State<CartDetailsPage> {
int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CustomerHomePage()),
      );
    } else if (index == 1) {
      //on cart page only
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart Details'),
      ),
      body: ListView.builder(
        itemCount: widget.cartItems.length,
        itemBuilder: (context, index) {
          final item = widget.cartItems[index];
          return ListTile(
            title: Text(item.title),
            subtitle: Text('Price: ₹${item.price}, GST: ₹${item.gst}, Service Charges: ₹${item.serviceCharges}, Total: ₹${item.totalPrice}'),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}