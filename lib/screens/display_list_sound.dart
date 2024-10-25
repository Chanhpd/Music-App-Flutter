import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music/screens/all_sound_screen.dart';
import 'package:music/themes/colors.dart';
import 'package:provider/provider.dart';

import '../model/song.dart';
import '../utils/user_preferences.dart';

import 'components/audio_provider.dart';
import 'components/mini_player.dart';
import 'display_screen.dart';

class ListSoundScreen extends StatefulWidget {
  static const String id = 'list_sound_screen';

  const ListSoundScreen({super.key});

  @override
  State<ListSoundScreen> createState() => _ListSoundScreenState();
}

class _ListSoundScreenState extends State<ListSoundScreen> {
  final store = FirebaseFirestore.instance;
  var isLoginFuture = UserPreferences.isLogin;
  final yourName = UserPreferences.getYourName();



  @override
  void initState() {
    super.initState();
    UserPreferences.isLogin();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Home',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold)),
      ),

      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              Row(
                children: [
                  Image(image: AssetImage('assets/logo.png'), height: 50),
                  SizedBox(width: 10),
                  Text('Welcome back!',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 22,
                      )),

                ],
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Text('Suggestions for you',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              SizedBox(
                height: 260,
                child: StreamBuilder(
                  stream: store.collection('songs')
                      .limit(12).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Something went wrong'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // lấy danh sách bài hát từ Firestore
                    var songs = snapshot.data?.docs.map((doc) {
                      return Song.fromFirestore(doc.data(), doc.id);
                    }).toList();
                    songs?.shuffle();

                    return ListView.builder(
                        itemCount: songs?.length ?? 0,
                        scrollDirection: Axis.horizontal,
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).colorScheme.outline,
                                          offset: Offset(4, 4),
                                          blurRadius: 6,
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontSize: 14)),
                              ],
                            ),
                          );
                        });
                  },
                ),
              ),
              SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Text('My playlist',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(height: 12),
              FutureBuilder<String>(
                future: UserPreferences.getUserID(),
                builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
                }
                if (userSnapshot.hasError) {
                return const Center(child: Text('Failed to load user ID'));
                }
                final userId = userSnapshot.data;
                return SizedBox(
                  height: 260,
                  child: StreamBuilder(
                    stream: store
                        .collection('songs')
                        .where('userId', isEqualTo: userId)
                        .limit(8)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(child: Text('Something went wrong'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // lấy danh sách bài hát từ Firestore
                      var songs = snapshot.data?.docs.map((doc) {
                        return Song.fromFirestore(doc.data(), doc.id);
                      }).toList();

                      return ListView.builder(
                          itemCount: songs?.length ?? 0,
                          scrollDirection: Axis.horizontal,
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
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context).colorScheme.outline,
                                            offset: Offset(4, 4),
                                            blurRadius: 6,
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
                                      style: const TextStyle(

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
                                          fontSize: 14)),
                                ],
                              ),
                            );
                          });
                    },
                  ),
                );

                }
              ),
              const SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Explore',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AllSoundScreen.id);
                        },
                        child: Text('View all',
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 600,
                child: StreamBuilder(
                  stream: store.collection('songs')
                      .limit(15)
                      .orderBy('created_at', descending: true)
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

                          return Container(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(song.imageUrl),
                              ),
                              title: Text(song.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(song.author,
                                  style: TextStyle(color: Colors.blueGrey)),
                              onTap: () {
                                // Chuyển sang
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
                            ),
                          );
                        });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
