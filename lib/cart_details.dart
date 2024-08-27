import 'package:flutter/material.dart';
import 'cart_item.dart';
import 'cart_manager.dart';
import 'customer_home_page.dart';

class CartDetailsPage extends StatefulWidget {
  final List<CartItem> cartItems;

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
      body: CartManager.cartItems.isEmpty
          ? Center(child: Text('No items in cart'))
          : ListView.builder(
        itemCount: CartManager.cartItems.length,
        itemBuilder: (context, index) {
          final item = CartManager.cartItems[index];
          return ListTile(
            title: Text(item.title),
            subtitle: Text('Price: \$${item.price.toStringAsFixed(2)}\n'
                'GST: \$${item.gst.toStringAsFixed(2)}\n'
                'Service Charges: \$${item.serviceCharges.toStringAsFixed(2)}\n'
                'Total: \$${item.totalPrice.toStringAsFixed(2)}'),
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