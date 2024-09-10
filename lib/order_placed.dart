import 'package:flutter/material.dart';
import 'dart:async';
import 'package:snippet_coder_utils/hex_color.dart';
import 'customer_home_page.dart';

class OrderPlacedSplash extends StatefulWidget {
  const OrderPlacedSplash({Key? key}) : super(key: key);

  @override
  _OrderPlacedSplashState createState() => _OrderPlacedSplashState();
}

class _OrderPlacedSplashState extends State<OrderPlacedSplash> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CustomerHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: HexColor("#283B71"),
              size: 150.0,
            ),
            const SizedBox(height: 20.0),
            Text(
              'Order Placed',
              style: TextStyle(
                color: HexColor("#283B71"),
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
