import 'package:cooking_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cooking_app/login_page.dart';
import 'package:cooking_app/register_page.dart';
import 'package:cooking_app/customer_home_page.dart';
import 'package:cooking_app/cook_home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sign Up Page",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/customer_home": (context) => const CustomerHomePage(),
        "/cook_home": (context) => const CookHomePage(),
      },
    );
  }
}
