import 'dart:io';
import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

class CookHomePage extends StatefulWidget {
  const CookHomePage({Key? key}) : super(key: key);

  @override
  _CookHomePageState createState() => _CookHomePageState();
}

class _CookHomePageState extends State<CookHomePage> {
  final List<Item> _items = [];

  void _addItem(String title, String description, String fileUrl) {
    setState(() {
      _items.add(Item(title: title, description: description, fileUrl: fileUrl));
    });

    FirebaseFirestore.instance.collection('cooking_items').add({
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
    });
  }

  void _showAddItemDialog() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    PlatformFile? pickedFile;

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
                ElevatedButton(
                  onPressed: () async {
                    // File Picker
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result != null && result.files.isNotEmpty) {
                      pickedFile = result.files.first;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('File selected: ${pickedFile?.name}')),
                      );
                    }
                  },
                  child: const Text('Select File'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final title = titleController.text;
                final description = descriptionController.text;
                if (title.isNotEmpty && description.isNotEmpty && pickedFile != null) {
                  try {

                    String fileUrl = await _uploadFile(pickedFile!);
                    _addItem(title, description, fileUrl);
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

  Future<String> _uploadFile(PlatformFile pickedFile) async {
    File file = File(pickedFile.path!);
    try {

      Reference ref = FirebaseStorage.instance.ref().child('uploads/${pickedFile.name}');

      await ref.putFile(file);

      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#283B71"),
      appBar: AppBar(
        title: const Text("Cook Home Page"),
        backgroundColor: HexColor("#283B71"),
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/khanawal_logo.png'),
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
                  const SizedBox(width: 10), // Space between image and text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: TextStyle(color: HexColor("#283B71"), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5), // Space between title and description
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
                    title: Text('Profile', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text('Settings', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                ],
              ),
            ),
            ListTile(
              title: Text('Accounts', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Item {
  final String title;
  final String description;
  final String fileUrl;

  Item({required this.title, required this.description, required this.fileUrl});
}
