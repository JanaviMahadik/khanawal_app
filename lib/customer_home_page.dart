import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooking_app/profile_setting_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'cart_details.dart';
import 'cart_manager.dart';
import 'cook_home_page.dart';
import 'item_details_page.dart';

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
  int _selectedIndex = 0;
  int _cartItemCount = 0;

  void _onItemTapped(int index) {
    if (index == 0) {
      //on home page only
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return CartDetailsPage(cartItems: CartManager.cartItems);
          },
        ),
      );
    }

    setState(() {
      _selectedIndex = index;
    });
  }

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
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final url = 'http://192.168.31.174:3000/items';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final List<dynamic> itemsData = jsonDecode(response.body);
          setState(() {
            _allItems.clear();
            _filteredItems.clear();
            for (var data in itemsData) {
              _allItems.add(Item(
                id: data['_id'],
                title: data['title'] ?? '',
                description: data['description'] ?? '',
                fileUrl: data['fileUrl'] ?? '',
                price: double.tryParse(data['price']) ?? 0.0,
                gst: double.tryParse(data['gst'].toString()) ?? 0.0,
                serviceCharges: double.tryParse(data['serviceCharges'].toString()) ?? 0.0,
                totalPrice: double.tryParse(data['totalPrice'].toString()) ?? 0.0,
              ));
              _filteredItems.add(Item(
                id: data['_id'],
                title: data['title'] ?? '',
                description: data['description'] ?? '',
                fileUrl: data['fileUrl'] ?? '',
                price: double.tryParse(data['price']) ?? 0.0,
                gst: double.tryParse(data['gst'].toString()) ?? 0.0,
                serviceCharges: double.tryParse(data['serviceCharges'].toString()) ?? 0.0,
                totalPrice: double.tryParse(data['totalPrice'].toString()) ?? 0.0,
              ));
            }
          });
        } else {
          print('Error fetching items: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching user items: $e');
      }
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final userId = user.uid;

        if (user.photoURL != null) {
          final ref = FirebaseStorage.instance.refFromURL(user.photoURL!);
          await ref.delete();
        }

        final collections = [
          'cooking_items',
          'users',
        ];

        for (var collection in collections) {
          final querySnapshot = await FirebaseFirestore.instance
              .collection(collection)
              .where('userId', isEqualTo: userId)
              .get();
          for (var doc in querySnapshot.docs) {
            await doc.reference.delete();
          }
        }

        await FirebaseFirestore.instance.collection('users').doc(userId).delete();
        await user.delete();

        Navigator.pushReplacementNamed(context, '/');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: $e')),
        );
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAccount();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _loadCartItemCount() {
    setState(() {
      _cartItemCount = CartManager.cartItems.length;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserProfilePhoto();
    _getDisplayName();
    _fetchAllItems();
    _loadCartItemCount();
    _searchController.addListener(() {
      _filterItems(_searchController.text);
    });
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
                        Text(item.title,
                            style: TextStyle(
                                color: HexColor("#283B71"),
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(item.description,
                            style: TextStyle(
                                color: HexColor("#283B71"))),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ItemDetailsPage(
                          title: item.title,
                          description: item.description,
                          fileUrl: item.fileUrl,
                          price: item.price.toString(),
                          gst: item.gst.toString(),
                          serviceCharges: item.serviceCharges.toString(),
                          totalPrice: item.totalPrice.toString(),
                        ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                if (_cartItemCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1.0),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12.0,
                        minHeight: 12.0,
                      ),
                      child: Center(
                        child: Text(
                          '$_cartItemCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
                    'Delete Account',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteAccountDialog();
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
