import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:music/model/song.dart';

import '../utils/user_preferences.dart';


class EditSongScreen extends StatefulWidget {
  final Song song;

  const EditSongScreen({super.key, required this.song});

  @override
  State<EditSongScreen> createState() => _EditSongScreenState();
}

class _EditSongScreenState extends State<EditSongScreen> {
  File? _imageFile; //
  final TextEditingController _nameController = TextEditingController();
  bool isChooseNewImage = false;
  late Future<String> _userID ;

  final picker = ImagePicker();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _userID = UserPreferences.getUserID();
    // khởi tạo giá trị cho _nameController và _authorController
    _nameController.text = widget.song.name;


    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
  }
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Lưu file ảnh được chọn
        isChooseNewImage = true; // Đánh dấu rằng người dùng đã chọn ảnh mới
      });
    }
  }

  Future<void> _updateSong() async {
    // Kiểm tra xem người dùng đã chọn ảnh mới chưa
    if (_imageFile != null && isChooseNewImage) {
      // Upload ảnh mới lên Firebase Storage
      var ref = FirebaseStorage.instance
          .ref()
          .child('images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(_imageFile!);

      // Lấy URL của ảnh mới
      var imageUrl = await ref.getDownloadURL();

      // Cập nhật ảnh mới vào Firestore
      await FirebaseFirestore.instance
          .collection('songs')
          .doc(widget.song.id)
          .update({'imageUrl': imageUrl});
    }

    String userID = await _userID;

    // Cập nhật tên và tác giả mới vào Firestore
    await FirebaseFirestore.instance
        .collection('songs')
        .doc(widget.song.id)
        .update({
      'name': _nameController.text,
      'userId': userID,

    });
    const SnackBar(content: Text('Updated successfully'));
    Navigator.pop(context);
  }



   Future<void> _dialogConfirmDelete(BuildContext context, Song song) async {
    showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xff333333),
        title: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
        content: const Text('Bạn có muốn xoá file này không?',
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng hộp thoại nếu hủy
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () {
              _deleteSong();
              Navigator.of(context).pop(); // Đóng hộp thoại

            },
            child: const Text(
                'Continue delete', style: TextStyle(color: Colors.green)),
          ),
        ],
      );
    });
  }

  Future<void> _deleteSong() async {
    await FirebaseFirestore.instance
        .collection('songs')
        .doc(widget.song.id)
        .delete();

    Navigator.pop(context);
  }

  Future<void> _playSong() async {
    await _audioPlayer.play(UrlSource(widget.song.mp3Url));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(

        title: const Text('Edit this sound',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        iconTheme:  IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_imageFile != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _imageFile!,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1.0), // Outline color and width
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.song.imageUrl,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      onPressed: _playSong,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image_rounded, color: Colors.white),
                  onPressed: _pickImage,
                  label: const Text(
                    'Choose',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            ),

            const SizedBox(height: 20),
            // Button chọn ảnh

            const SizedBox(height: 20),

            TextField(

              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Sound Name',

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  // outline màu trắng
                ),
              ),
            ),

            const SizedBox(height: 10),


            // Button thêm bài hát
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    _updateSong();
                  },
                  label: const Text('Edit Song',
                      style: TextStyle(color: Colors.white)),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                const SizedBox(width: 60),
                ElevatedButton.icon(
                  icon:
                      const Icon(Icons.remove_done_sharp, color: Colors.white),
                  onPressed: () {
                    _dialogConfirmDelete(context, widget.song);
                  },
                  label: const Text('Delete Song',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
