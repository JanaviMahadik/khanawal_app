import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooking_app/profile_setting_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/hex_color.dart';

import 'cook_home_page.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({Key? key}) : super(key: key);

  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  bool _isAccountsExpanded = false;
  String? _profilePhotoUrl;
  String? _displayName;
  final List<Item> _allItems = [];
  List<Item> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();

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

  Future<void> _getDisplayName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      setState(() {
        _displayName = user.displayName;
      });
    }
  }

  Future<void> _updateDisplayName(String newName) async {
    setState(() {
      _displayName = newName;
    });
  }

  Future<void> _fetchAllItems() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('cooking_items')
          .get();

      setState(() {
        _allItems.clear();
        _filteredItems.clear();
        for (var doc in querySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;

          if (data != null) {
            final item = Item(
              title: data['title'] ?? 'No Title',
              description: data['description'] ?? 'No Description',
              fileUrl: data['fileUrl'] ?? '',
            );
            _allItems.add(item);
            _filteredItems.add(item);
          }
        }
      });
    } catch (e) {
      print("Error fetching items: $e");
    }
  }

  void _filterItems(String query) {
    final filteredItems = _allItems.where((item) {
      final itemTitle = item.title.toLowerCase();
      final searchQuery = query.toLowerCase();
      return itemTitle.contains(searchQuery);
    }).toList();

    setState(() {
      _filteredItems = filteredItems;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserProfilePhoto();
    _getDisplayName();
    _fetchAllItems();
    _searchController.addListener(() {
      _filterItems(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_displayName ?? "Customer Home Page",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
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
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Container(
    height: 30.0,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by title...',
              hintStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(30.0),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              prefixIcon: Icon(Icons.search, color: Colors.white),
            ),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    ),
      ),
      body: _filteredItems.isEmpty
          ? Center(child: Text("No items available"))
          : ListView.builder(
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            color: Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.all(10.0),
              title: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        image: NetworkImage(item.fileUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: TextStyle(color: HexColor("#283B71"), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(item.description, style: TextStyle(color: HexColor("#283B71"))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
                        MaterialPageRoute(
                          builder: (context) => ProfileSettingsPage(
                            onUpdateDisplayName: _updateDisplayName,
                          ),
                        ),
                      );

                      if (result == true) {
                        _getUserProfilePhoto();
                        _getDisplayName();
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
