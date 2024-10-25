class User {
  final String id;
  final String? username;
  final String name;
  final  String? password;
  // thêm danh sách id các bài hát yêu thích
  final List<String> favoriteSongs;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.password,
    required this.favoriteSongs,
  });

  factory User.fromFirestore(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      username: data['username'] ?? 'Unknown Username',
      name: data['name'] ?? 'Unknown Name',
      password: data['password'] ?? 'Unknown Password',
      favoriteSongs: List<String>.from(data['favoriteSongs'] ?? []),
    );
  }
}