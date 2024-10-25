import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/song.dart';
import '../themes/colors.dart';
import '../utils/user_preferences.dart';
import 'display_screen.dart';


class LikedTracksScreen extends StatefulWidget {
  static const String id = 'liked_tracks_screen';
  const LikedTracksScreen({super.key});

  @override
  State<LikedTracksScreen> createState() => _LikedTracksScreenState();
}

class _LikedTracksScreenState extends State<LikedTracksScreen> {
  final store = FirebaseFirestore.instance;
  late Future<String> _userIdFuture;

  @override
  void initState() {

    super.initState();
    _userIdFuture = UserPreferences.getUserID();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,

        title: const Text('Liked Tracks',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      ),

      body: FutureBuilder<String>(
        future: _userIdFuture, // Lấy dữ liệu author từ UserPreferences
        builder: (context, userIdSnapshot) {

          if (userIdSnapshot.hasError || !userIdSnapshot.hasData) {
            return const Center(child: Text('Error fetching author data')); // Hiển thị lỗi nếu không lấy được dữ liệu
          }

          String userId  = userIdSnapshot.data ?? '';

          return FutureBuilder<DocumentSnapshot>(
            future: store.collection('users').doc(userId).get(),

            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text('Error fetching user data'));
              }

              List<dynamic> favoriteSongsIds = snapshot.data?.get('favoriteSongs') ?? [];

              if(favoriteSongsIds.isEmpty) {
                return const Center(child: Text('You have not liked any songs yet' , style: TextStyle(color: Colors.white)));
              }

              return StreamBuilder(
                stream: store.collection('songs')
                    .where(FieldPath.documentId, whereIn: favoriteSongsIds)
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

               return GridView.builder(
                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                   crossAxisCount: 2, // Số cột
                   crossAxisSpacing: 0, // Khoảng cách giữa các cột
                   mainAxisSpacing: 0, // Khoảng cách giữa các dòng
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
                     child: Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 4.0),
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Container(
                             margin: const EdgeInsets.all(10),
                             decoration: BoxDecoration(
                                 color: Theme.of(context).colorScheme.background,
                                 borderRadius: BorderRadius.circular(4),
                                 boxShadow: const [
                                   BoxShadow(
                                     color:
                                      // Theme.of(context).colorScheme.outline,
                                        Colors.blueGrey,
                                     offset: Offset(0, 10),
                                     blurRadius: 20,
                                   )
                                 ]),
                             child: ClipRRect(
                               borderRadius: BorderRadius.circular(4),
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
                     ),
                   );
                 },
               );
             },
              );
            },
          );
        },
      ),
    );
  }
}