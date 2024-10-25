import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/song.dart';
import '../themes/colors.dart';
import 'display_screen.dart';
import 'menu/navigation_menu.dart';

class AllSoundScreen extends StatefulWidget {
  static const id = 'all_sound_screen';

  const AllSoundScreen({super.key});

  @override
  State<AllSoundScreen> createState() => _AllSoundScreenState();
}

class _AllSoundScreenState extends State<AllSoundScreen> {
  final store = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Sounds',
            style: TextStyle(

                fontSize: 24,
                fontWeight: FontWeight.bold)),

        iconTheme: const IconThemeData( size: 30),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: store.collection('songs').snapshots(),
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

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Số cột
                    crossAxisSpacing: 10.0, // Khoảng cách giữa các cột
                    mainAxisSpacing: 10.0, // Khoảng cách giữa các dòng
                    childAspectRatio:
                        0.75, // Tỷ lệ chiều rộng / chiều cao của mỗi item
                  ),
                  itemCount: songs?.length ?? 0,
                  itemBuilder: (context, index) {
                    // Dữ liệu từng bài hát
                    var song = songs![index];

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DisplayMusic(
                              songList: songs,
                              // Truyền danh sách bài hát
                              initialIndex:
                                  index, // Vị trí của bài hát được chọn
                            ),
                          ),
                        );
                      },
                      child: Column(
                        // height: 150,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    offset: Offset(4, 4),
                                    blurRadius: 4,
                                  )
                                ]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image(
                                  image: NetworkImage(song.imageUrl),
                                  height: 180,
                                  width: 180,
                                  fit: BoxFit.cover),
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: 180,
                            // Giới hạn độ rộng của Text để điều chỉnh hiển thị tên
                            child: Text(
                              textAlign: TextAlign.center,
                              song.name,

                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              // Giới hạn tên bài hát chỉ hiển thị 1 dòng
                              overflow: TextOverflow
                                  .ellipsis, // Thêm dấu ba chấm nếu tên quá dài
                            ),
                          ),
                          Text(song.author,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 14)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // bottomNavigationBar: NavigationMenu(indexScreen: 0),
    );
  }
}
