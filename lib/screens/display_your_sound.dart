import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music/utils/user_preferences.dart';

import '../model/song.dart';
import '../themes/colors.dart';
import 'add_song_screen.dart';
import 'display_screen.dart';
import 'edit_song_screen.dart';

class DisplayYourSound extends StatefulWidget {
  static const id = 'display_your_sound';

  const DisplayYourSound({super.key});

  @override
  State<DisplayYourSound> createState() => _DisplayYourSoundState();
}

class _DisplayYourSoundState extends State<DisplayYourSound> {
  final store = FirebaseFirestore.instance;
  late Future<String> _author;

  // lấy tên người dùng từ UserPreferences

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _author = UserPreferences.getYourName();
  }

  void _showConfirmationDialog(BuildContext context, Song song) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xff333333),
            title:
                const Text('Confirm', style: TextStyle(color: Colors.white)),
            content: const Text('Do you want to edit this sound?',
                style: TextStyle(color: Colors.white)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng hộp thoại nếu hủy
                },
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.redAccent)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng hộp thoại
                  _navigateToEditSongScreen(
                      context, song); // Chuyển tới trang chỉnh sửa
                },
                child: const Text('Yes',
                    style: TextStyle(color: Colors.green)),
              ),
            ],
          );
        });
  }

  void _navigateToEditSongScreen(BuildContext context, Song song) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditSongScreen(song: song), // Chuyển tới trang chỉnh sửa bài hát
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Your Library',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, AddNewSongScreen.id);
                },
                icon: Icon(Icons.more_vert, color: Colors.white))
          ],
        ),
      ),
      body: FutureBuilder<String>(
        future: _author, // Lấy dữ liệu author từ UserPreferences
        builder: (context, authorSnapshot) {
          if (authorSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Hiển thị khi đang chờ lấy dữ liệu author
          }

          if (authorSnapshot.hasError || !authorSnapshot.hasData) {
            return const Center(
                child: Text(
                    'Error fetching author data')); // Hiển thị lỗi nếu không lấy được dữ liệu
          }

          String author = authorSnapshot.data ?? '';

          return StreamBuilder(
            stream: store
                .collection('songs')
                .where('author', isEqualTo: author)
                .orderBy('name')

                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Lấy danh sách bài hát từ Firestore
              var songs = snapshot.data?.docs.map((doc) {
                return Song.fromFirestore(doc.data(), doc.id);
              }).toList();

              return ListView.builder(
                  itemCount: songs?.length ?? 0,
                  itemBuilder: (context, index) {
                    // Dữ liệu từng bài hát
                    var song = songs![index];

                    return ListTile(

                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(song.imageUrl),
                      ),
                      title: Text(
                        song.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      subtitle: Text(song.author,
                          style: TextStyle(color: Colors.blueGrey)),
                      onTap: () {
                        // Chuyển sang trang phát bài hát
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DisplayMusic(
                              songList: songs, // Truyền danh sách bài hát
                              initialIndex:
                                  index, // Vị trí của bài hát được chọn
                            ),
                          ),
                        );
                      },
                      trailing: IconButton(onPressed:() {
                        _showConfirmationDialog(context, song);
                      }, icon: Icon(Icons.ac_unit_sharp , size: 24,),),

                      onLongPress: () {
                        _showConfirmationDialog(context, song);
                      },
                    );
                  });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          // Thêm hành động cho việc thêm bài hát tại đây
          // Ví dụ: Chuyển sang màn hình thêm bài hát mới
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddNewSongScreen(), // Chuyển sang trang thêm bài hát mới
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
          weight: 900,
        ), // Biểu tượng dấu cộng (+)
      ),
    );
  }
}
