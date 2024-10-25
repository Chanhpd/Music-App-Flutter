import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:music/screens/menu/navigation_menu.dart';
import 'package:music/themes/colors.dart';
import 'package:music/utils/user_preferences.dart';
import 'package:path/path.dart' as path;

class AddNewSongScreen extends StatefulWidget {
  static const String id = 'add_new_song_screen';

  const AddNewSongScreen({super.key});

  @override
  State<AddNewSongScreen> createState() => _AddNewSongScreenState();
}

class _AddNewSongScreenState extends State<AddNewSongScreen> {
  final TextEditingController _nameController = TextEditingController();
  late Future<String> _author;
  late Future<String> _userID;

  File? _imageFile; // Lưu file ảnh được chọn
  File? _mp3File; // Lưu file âm thanh được chọn
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _author = UserPreferences.getYourName();
    _userID = UserPreferences.getUserID();


  }

  // Chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Lưu file ảnh được chọn
      });
    }
  }

  //  Hàm để hiển thị dialog loading
  void _showLoadingDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Uploading..."),
                ],
              ),
            ),
          );
        });
  }

  // Chọn file âm thanh từ thiết bị
  Future<void> _pickMp3() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null && result.files.single.path != null) {
      setState(() {
        _mp3File = File(result.files.single.path!); // Lưu file mp3 được chọn
        _nameController.text = path.basename(_mp3File!.path);
      });
    }
  }

  // Upload ảnh và âm thanh lên Firebase Storage
  Future<void> _uploadSong() async {
    if (_imageFile == null || _mp3File == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both an image and a song')),
      );
      return;
    }

    // Upload ảnh lên Firebase Storage
    String imageUrl = '';
    String mp3Url = '';

    try {
      _showLoadingDialog(context);

      // Upload file ảnh
      String imageFileName =
          'images/${DateTime.now().millisecondsSinceEpoch}.png';
      final imageRef = _storage.ref().child(imageFileName);
      await imageRef.putFile(_imageFile!);
      imageUrl = await imageRef.getDownloadURL(); // Lấy URL ảnh

      // Upload file âm thanh
      String mp3FileName = 'songs/${DateTime.now().millisecondsSinceEpoch}.mp3';
      final mp3Ref = _storage.ref().child(mp3FileName);
      await mp3Ref.putFile(_mp3File!);
      mp3Url = await mp3Ref.getDownloadURL(); // Lấy URL mp3

      final authorName = await _author;
      final userID = await _userID;
      print('userID: $userID');

      // Lưu thông tin vào Firestore
      _store.collection('songs').add({
        'name': _nameController.text,
        'author': authorName,
        'imageUrl': imageUrl,
        'mp3Url': mp3Url,
        'userId': userID,
        'create_at': DateTime.now(),
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Song added successfully')),

          // Đóng loading dialog
        );
        // Trở lại màn hình list sound
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const NavigationMenu(indexScreen: 3)));
      }).catchError((error) {
        Navigator.pop(context); // Đóng loading dialog
        print('Failed to add song: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add song: $error')),

        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: const Text('Add New Sound',
            style: TextStyle( fontSize: 24, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(size: 30),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Song Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Button chọn ảnh
            ElevatedButton.icon(
              icon: const Icon(Icons.image, color: Colors.white),
              onPressed: _pickImage,
              label: const Text(
                'Pick Image',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),

            if (_imageFile != null)
              Image.file(
                _imageFile!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),

            const SizedBox(height: 20),

            // Button chọn file âm thanh
            ElevatedButton.icon(
              icon: const Icon(Icons.audiotrack, color: Colors.white),
              onPressed: _pickMp3,
              label:
                  const Text('Pick MP3', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),

            if (_mp3File != null)
              Text('MP3 selected: ${path.basename(_mp3File!.path)}',
                  style: const TextStyle(color: Colors.blueGrey)),

            const SizedBox(height: 20),
            // Button thêm bài hát
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outlined, color: Colors.white),
              onPressed: _uploadSong,
              label:
                  const Text('Add Song', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
