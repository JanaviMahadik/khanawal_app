import 'dart:convert';
import 'dart:io';
import 'package:cooking_app/profile_setting_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CookHomePage extends StatefulWidget {
  const CookHomePage({Key? key}) : super(key: key);

  @override
  _CookHomePageState createState() => _CookHomePageState();
}

class _CookHomePageState extends State<CookHomePage> {
  final List<Item> _items = [];
  bool _isAccountsExpanded = false;
  String? _profilePhotoUrl;
  String? _displayName;
  int _currentIndex = 0;
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final userId = user.uid;

        QuerySnapshot itemsSnapshot = await FirebaseFirestore.instance
            .collection('cooking_items')
            .where('userId', isEqualTo: userId)
            .get();

        for (var doc in itemsSnapshot.docs) {
          String fileUrl = doc['fileUrl'];

          Reference storageRef = FirebaseStorage.instance.refFromURL(fileUrl);
          await storageRef.delete();
          await doc.reference.delete();
        }

        if (_profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty) {
          Reference profilePhotoRef = FirebaseStorage.instance.refFromURL(_profilePhotoUrl!);
          await profilePhotoRef.delete();
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

  @override
  void initState() {
    super.initState();
    _getUserProfilePhoto();
    _getDisplayName();
    _fetchUserItems();
  }

  void _addItem(String title, String description, String fileUrl, double price, double gst, double serviceCharges, double totalPrice) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;

      FirebaseFirestore.instance.collection('cooking_items').add({
        'title': title,
        'description': description,
        'fileUrl': fileUrl,
        'price': price,
        'userId': userId,
        'gst': gst,
        'serviceCharges': serviceCharges,
        'totalPrice': totalPrice,
      }).then((docRef) async {
        String mongoId = await _saveItemToMongoDB(title, description, fileUrl, price, gst, serviceCharges, totalPrice);
        setState(() {
          _items.add(Item(
            id: mongoId,
            title: title,
            description: description,
            fileUrl: fileUrl,
            price: price,
            gst: gst,
            serviceCharges: serviceCharges,
            totalPrice: totalPrice,
          ));
        });
      }).catchError((error) {
        print('Error adding item: $error');
      });
    }
  }

  Future<String> _saveItemToMongoDB(
      String title,
      String description,
      String fileUrl,
      double price,
      double gst,
      double serviceCharges,
      double totalPrice,
      //String userId,
      ) async {
    final url = 'http://192.168.31.174:3000/addItem';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'fileUrl': fileUrl,
          'price': price,
          'gst': gst,
          'serviceCharges': serviceCharges,
          'totalPrice': totalPrice,
        }),
      );

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return responseBody['mongoId'];
      } else {
        print('Failed to save item to MongoDB: ${response.body}');
        throw Exception('Failed to save item');
      }
    } catch (e) {
      print('Error saving item to MongoDB: $e');
      throw Exception('Error saving item');
    }
  }

  void _showAddItemDialog() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    XFile? pickedFile;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                ElevatedButton(
                  onPressed: () async {
                    XFile? file = await _picker.pickImage(source: ImageSource.camera);
                    if (file != null) {
                      pickedFile = file;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Photo taken: ${pickedFile?.name}')),
                      );
                    }
                  },
                  child: const Text('Capture Photo'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final title = titleController.text;
                final description = descriptionController.text;
                final price = double.tryParse(priceController.text) ?? 0.0;
                if (title.isNotEmpty && description.isNotEmpty && pickedFile != null) {
                  try {
                    double gst = price * 0.12;
                    double serviceCharges = price * 0.10;
                    double totalPrice = price + gst + serviceCharges;

                    String fileUrl = await _uploadFile(pickedFile!);
                    _addItem(title, description, fileUrl, price, gst, serviceCharges, totalPrice);
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error uploading file: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields and select a file')),
                  );
                }
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showEditItemDialog(Item item) {
    final TextEditingController titleController = TextEditingController(text: item.title);
    final TextEditingController descriptionController = TextEditingController(text: item.description);
    final TextEditingController priceController = TextEditingController(text: item.price.toString());
    XFile? pickedFile;
    final String mongoId = item.id;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                ElevatedButton(
                  onPressed: () async {
                    XFile? file = await _picker.pickImage(source: ImageSource.camera);
                    if (file != null) {
                      pickedFile = file;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Photo taken: ${pickedFile?.name}')),
                      );
                    }
                  },
                  child: const Text('Capture Photo'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final title = titleController.text;
                final description = descriptionController.text;
                final price = double.tryParse(priceController.text) ?? 0.0;

                if (title.isNotEmpty && description.isNotEmpty) {
                  try {
                    double gst = price * 0.12;
                    double serviceCharges = price * 0.10;
                    double totalPrice = price + gst + serviceCharges;

                    String fileUrl = pickedFile != null ? await _uploadFile(pickedFile!) : item.fileUrl;

                    await _updateItemInMongoDB(mongoId, title, description, fileUrl, price, gst, serviceCharges, totalPrice);

                    setState(() {
                      _items[_items.indexWhere((i) => i.id == mongoId)] = Item(
                        id: mongoId,
                        title: title,
                        description: description,
                        fileUrl: fileUrl,
                        price: price,
                        gst: gst,
                        serviceCharges: serviceCharges,
                        totalPrice: totalPrice,
                      );
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating item: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: const Text('Update'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateItemInMongoDB(String mongoId, String title, String description, String fileUrl, double price, double gst, double serviceCharges, double totalPrice) async {
    final url = 'http://192.168.31.174:3000/updateItem/$mongoId';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'fileUrl': fileUrl,
          'price': price,
          'gst': gst,
          'serviceCharges': serviceCharges,
          'totalPrice': totalPrice,
        }),
      );

      if (response.statusCode != 200) {
        print('Failed to update item. Status code: ${response.statusCode}, Response: ${response.body}');
        throw Exception('Failed to update item in MongoDB');
      }
    } catch (e) {
      print('Error updating item in MongoDB: $e');
      throw Exception('Error updating item');
    }
  }

  Future<void> _deleteItem(String mongoId, String fileUrl) async {
    try {
      final url = 'http://192.168.31.174:3000/deleteItem/$mongoId';
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        if (fileUrl.isNotEmpty) {
          Reference storageRef = FirebaseStorage.instance.refFromURL(fileUrl);
          await storageRef.delete();
        }

        setState(() {
          _items.removeWhere((item) => item.id == mongoId);
        });
      } else {
        throw Exception('Failed to delete item from MongoDB');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting item: $e')),
      );
    }
  }

  void _showDeleteConfirmationDialog(String mongoId, String fileUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text('Delete Item'),
            content: Text('Are you sure you want to delete this item?'),
            actions: [
            TextButton(
            onPressed: () => Navigator.of(context).pop(),
        child: Text('Cancel'),
        ),
        TextButton(
        onPressed: () async {
        Navigator.of(context).pop();
        await _deleteItem(mongoId, fileUrl);
        },
        child: Text('Delete'),
        ),
      ],
    );
  },
  );
}

Future<String> _uploadFile(XFile pickedFile) async {
    File file = File(pickedFile.path);
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance.ref().child('cooking_items').child(fileName);

      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => {});
      final fileUrl = await snapshot.ref.getDownloadURL();

      return fileUrl;
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }

  Future<void> _fetchUserItems() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('cooking_items')
          .where('userId', isEqualTo: user.uid)
          .get();

      setState(() {
        _items.clear();
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          _items.add(Item(
            id: doc.id,
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            fileUrl: data['fileUrl'] ?? '',
            price: (data['price'] as num).toDouble(),
            gst: (data['gst'] as num).toDouble(),
            serviceCharges: (data['serviceCharges'] as num).toDouble(),
            totalPrice: (data['totalPrice'] as num).toDouble(),
          ));
        }
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      // on home page only
    } else if (index == 1) {
      Navigator.pushNamed(context, '/orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_displayName ?? "Cook Home Page",
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
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            color: Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.all(10.0),
          title: GestureDetector(
          onTap: () => _showEditItemDialog(item),
          child: Row(
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
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmationDialog(item.id, item.fileUrl);
                    },
                  ),
                ],
              ),
            ),
            )
          );
        },
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        child: FloatingActionButton(
          onPressed: _showAddItemDialog,
          child: const Icon(Icons.add, color: Colors.white),
          tooltip: 'Add Item',
          backgroundColor: HexColor("#283B71"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
            side: BorderSide(color: Colors.white, width: 2.0),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
        ],
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

class Item {
  final String id;
  final String title;
  final String description;
  final String fileUrl;
  final double price;
  final double gst;
  final double serviceCharges;
  final double totalPrice;

  Item(
      {
        required this.id,
        required this.title, required this.description, required this.fileUrl, required this.price, required this.gst,
        required this.serviceCharges,
        required this.totalPrice,});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'price': price,
      'gst': gst,
      'serviceCharges': serviceCharges,
      'totalPrice': totalPrice,
    };
  }
}
