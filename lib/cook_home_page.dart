import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/hex_color.dart'; // Import HexColor if not already

class CookHomePage extends StatefulWidget {
  const CookHomePage({Key? key}) : super(key: key);

  @override
  _CookHomePageState createState() => _CookHomePageState();
}

class _CookHomePageState extends State<CookHomePage> {
  final List<Item> _items = [];

  void _addItem(String title, String description) {
    setState(() {
      _items.add(Item(title: title, description: description));
    });
  }

  void _showAddItemDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Item'),
          content: Column(
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final title = titleController.text;
                final description = descriptionController.text;
                if (title.isNotEmpty && description.isNotEmpty) {
                  _addItem(title, description);
                  Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#283B71"), // Use the same background color
      appBar: AppBar(
        title: const Text("Cook Home Page"),
        backgroundColor: HexColor("#283B71"), // Match AppBar color with LoginPage
        foregroundColor: Colors.white, // Text color for the AppBar
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
            color: Colors.white, // Card background color
            child: ListTile(
              title: Text(item.title, style: TextStyle(color: HexColor("#283B71"))), // Text color to match theme
              subtitle: Text(item.description),
            ),
          );
        },
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20.0), // Add spacing from the bottom
        child: FloatingActionButton(
          onPressed: _showAddItemDialog,
          child: const Icon(Icons.add, color: Colors.white), // Plus sign color
          tooltip: 'Add Item',
          backgroundColor: HexColor("#283B71"), // Background color for the button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0), // Make it circular
            side: BorderSide(
              color: Colors.white, // Border color
              width: 2.0, // Border width
            ),
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
                    title: Text(
                      'Profile',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
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
                  Spacer(),
                ],
              ),
            ),
            ListTile(
              title: Text(
                'Accounts',
                style: TextStyle(color: Colors.white),
              ),
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

  Item({required this.title, required this.description});
}
