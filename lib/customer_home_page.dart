import 'package:cooking_app/profile_setting_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/hex_color.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({Key? key}) : super(key: key);

  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  bool _isAccountsExpanded = false;
  String? _profilePhotoUrl;

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  Future<void> _getUserProfilePhoto() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      setState(() {
        _profilePhotoUrl = user.photoURL;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserProfilePhoto();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Home Page"),
        backgroundColor: HexColor("#283B71"),
        leading: Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: CircleAvatar(
                  backgroundImage: _profilePhotoUrl != null
                      ? NetworkImage(_profilePhotoUrl!)
                      : AssetImage('assets/khanawal_logo.png') as ImageProvider,
                  radius: 20,
                ),
              ),
            );
          },
        ),
      ),
      body: Center(
        child: Text(
          "Welcome to the Customer Home Page!",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: HexColor("#283B71"),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: HexColor("#283B71"),
                    ),
                    child: Text(
                      'Drawer Header',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Profile',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileSettingsPage()),
                      );

                      if (result == true) {
                        _getUserProfilePhoto();
                      }
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Settings',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to settings page
                    },
                  ),
                ],
              ),
            ),
            ExpansionTile(
              title: Text(
                'Accounts',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Icon(
                _isAccountsExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.white,
              ),
              onExpansionChanged: (bool expanded) {
                setState(() {
                  _isAccountsExpanded = expanded;
                });
              },
              children: <Widget>[
                ListTile(
                  title: Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _signOut(context);
                  },
                ),
                ListTile(
                  title: Text(
                    'Switch Account',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _signOut(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
