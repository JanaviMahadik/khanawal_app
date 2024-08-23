import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePhotoService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> updateProfilePhoto(File file) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is logged in');
      }

      String fileName = 'profile_photos/${user.uid}.png';
      Reference ref = _storage.ref(fileName);

      await ref.putFile(file);

      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }
}
