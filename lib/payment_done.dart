import 'package:flutter/material.dart';
import 'dart:async';
import 'package:snippet_coder_utils/hex_color.dart';
import 'customer_home_page.dart';

class PaymentDoneSplash extends StatefulWidget {
  const PaymentDoneSplash({Key? key}) : super(key: key);

  @override
  _PaymentDoneSplashState createState() => _PaymentDoneSplashState();
}

class _PaymentDoneSplashState extends State<PaymentDoneSplash> {
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
              'Payment Done',
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
