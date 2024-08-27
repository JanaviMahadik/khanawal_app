import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'cart_manager.dart';
import 'cart_item.dart';

class ItemDetailsPage extends StatelessWidget {
  final String title;
  final String description;
  final String fileUrl;
  final String price;
  final String gst;
  final String serviceCharges;
  final String totalPrice;

  const ItemDetailsPage({
    Key? key,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.price,
    required this.gst,
    required this.serviceCharges,
    required this.totalPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: HexColor("#283B71"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                          image: NetworkImage(fileUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: HexColor("#283B71"),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 16,
                        color: HexColor("#283B71"),
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Price:', style: TextStyle(fontSize: 18)),
                        Text('₹$price', style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('GST (12%):', style: TextStyle(fontSize: 18)),
                        Text('₹$gst', style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Service Charges (10%):', style: TextStyle(fontSize: 18)),
                        Text('₹$serviceCharges', style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Price:',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹$totalPrice',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {
                  final cartItem = CartItem(
                    title: title,
                    price: double.parse(price),
                    gst: double.parse(gst),
                    serviceCharges: double.parse(serviceCharges),
                    totalPrice: double.parse(totalPrice),
                  );
                  CartManager.addItem(cartItem);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$title added to cart!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                  backgroundColor: Colors.green, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
