import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'profile_photo_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class ProfileSettingsPage extends StatefulWidget {
  final Function(String) onUpdateDisplayName;

  const ProfileSettingsPage({Key? key, required this.onUpdateDisplayName}) : super(key: key);

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  File? _selectedProfilePhoto;
  String? _username;
  String? _email;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _username = user.displayName ?? '';
        _email = user.email;
      });
    }
  }

  Future<void> _selectProfilePhotoOption() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickPhotoFromGallery();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickPhotoFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedProfilePhoto = File(result.files.single.path!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No photo selected. Please try again.')),
      );
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _selectedProfilePhoto = File(photo.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No photo captured. Please try again.')),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updateDisplayName(_username);
          widget.onUpdateDisplayName(_username!);

          await _updateUsernameInMongoDB(_email!, _username!);

          if (_selectedProfilePhoto != null) {
            ProfilePhotoService photoService = ProfilePhotoService();
            String? downloadUrl = await photoService.updateProfilePhoto(_selectedProfilePhoto!);
            await user.updatePhotoURL(downloadUrl);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')),
          );

          Navigator.pop(context, true);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  Future<void> _updateUsernameInMongoDB(String email, String newUsername) async {
    final url = Uri.parse('http://192.168.31.174:3000/updateUsername');

    final body = json.encode({
      'email': email,
      'newUsername': newUsername,
    });

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      print('Username updated successfully');
    } else {
      print('Failed to update username in MongoDB: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
        "Profile Settings",
        style: TextStyle(
        color: Colors.white,
    ),
        ),
        backgroundColor: HexColor("#283B71"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32.0),
              Text(
                'Update Profile',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: HexColor("#283B71"),
                ),
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: _selectProfilePhotoOption,
                child: _selectedProfilePhoto != null
                    ? CircleAvatar(
                  radius: 80,
                  backgroundImage: FileImage(_selectedProfilePhoto!),
                )
                    : CircleAvatar(
                  radius: 80,
                  backgroundColor: HexColor("#283B71"),
                  child: Icon(
                    Icons.add_a_photo,
                    color: Colors.white,
                    size: 40.0,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                initialValue: _username,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
                onSaved: (value) {
                  _username = value;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor("#283B71"),
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
