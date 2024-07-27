import 'package:flutter/material.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Home Page"),
      ),
      body: const Center(
        child: Text("Welcome to the Customer Home Page!"),
      ),
    );
  }
}
