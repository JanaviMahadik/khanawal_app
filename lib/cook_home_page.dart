import 'package:flutter/material.dart';

class CookHomePage extends StatelessWidget {
  const CookHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cook Home Page"),
      ),
      body: const Center(
        child: Text("Welcome to the Cook Home Page!"),
      ),
    );
  }
}
