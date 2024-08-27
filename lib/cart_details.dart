import 'package:flutter/material.dart';
import 'cart_item.dart';
import 'cart_manager.dart';
import 'customer_home_page.dart';
import 'payment_done.dart';

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
        MaterialPageRoute(builder: (context) => const CustomerHomePage()),
      );
    } else if (index == 1) {
      // On cart page only
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentDoneSplash(),
      ),
    );

    //CartManager.clearCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart Details'),
      ),
      body: CartManager.cartItems.isEmpty
          ? const Center(child: Text('No items in cart'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: CartManager.cartItems.length,
              itemBuilder: (context, index) {
                final item = CartManager.cartItems[index];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text(
                    'Price: \$${item.price.toStringAsFixed(2)}\n'
                        'GST: \$${item.gst.toStringAsFixed(2)}\n'
                        'Service Charges: \$${item.serviceCharges.toStringAsFixed(2)}\n'
                        'Total: \$${item.totalPrice.toStringAsFixed(2)}',
                  ),
                );
              },
            ),
          ),
          if (CartManager.cartItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _handleCheckout,
                child: const Text('Check Out'),
              ),
            ),
        ],
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
