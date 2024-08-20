import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:snippet_coder_utils/hex_color.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({Key? key}) : super(key: key);

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  File? _selectedProfilePhoto;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _selectProfilePhoto() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedProfilePhoto = File(result.files.single.path!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No photo selected. Please try again.')),
      );
    }
  }

  Future<void> _updateProfilePhoto() async {
    if (_selectedProfilePhoto != null) {
      try {
        User? user = _auth.currentUser;
        String fileName = 'profile_photos/${user!.uid}.png';

        await _storage.ref(fileName).putFile(_selectedProfilePhoto!);

        String downloadUrl = await _storage.ref(fileName).getDownloadURL();

        await user.updatePhotoURL(downloadUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile photo updated!')),
        );

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile photo: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a photo first.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Settings"),
        backgroundColor: HexColor("#283B71"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32.0),
            Text(
              'Update Profile Photo',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: HexColor("#283B71"),
              ),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: _selectProfilePhoto,
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
            ElevatedButton(
              onPressed: _updateProfilePhoto,
              style: ElevatedButton.styleFrom(
                primary: HexColor("#283B71"),
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
    );
  }
}
