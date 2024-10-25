import 'package:cloud_firestore/cloud_firestore.dart';

class Song {
  final String id;
  final String name;
  final String author;
  final String imageUrl;
  final String mp3Url;
  final String userId;
  final DateTime created_at;
  Song({
    required this.id,
    required this.name,
    required this.author,
    required this.imageUrl,
    required this.mp3Url,
    required this.userId,
    required this.created_at,
  });

  // Tạo một factory để dễ dàng khởi tạo đối tượng Song từ Firestore
  factory Song.fromFirestore(Map<String, dynamic> data , String id) {
    return Song(
      id: id,
      name: data['name'] ?? 'Unknown Name',
      author: data['author'] ?? 'Unknown Author',
      imageUrl: data['imageUrl'] ?? '',
      mp3Url: data['mp3Url'] ?? '',
      userId: data['userId'] ?? '',
      created_at: data['created_at'] is Timestamp
          ? (data['created_at'] as Timestamp).toDate() // Chuyển Timestamp sang DateTime
          : DateTime.now(),
    );
  }

  // Hàm để chuyển đổi ngược từ đối tượng Song thành Map (nếu cần)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'author': author,
      'imageUrl': imageUrl,
      'mp3Url': mp3Url,
      'userId': userId,
      'created_at': Timestamp.fromDate(created_at), // Chuyển DateTime sang Timestamp để lưu Firestore
    };
  }

}
