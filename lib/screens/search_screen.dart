import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/song.dart';
import '../themes/colors.dart';
import 'display_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  String _searchText = '';
  List<Song> _searchResults = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _performSearch('');
  }

  void _performSearch(String query) async {
    // Xử lý hành động tìm kiếm với query
    setState(() {
      _searchText = query;
      _searchResults = [];
    });

    // Thực hiện tìm kiếm từ Firestore
    await _search(query);
  }

  Future<void> _search(String query) async {
    // Tìm kiếm dữ liệu trong Firestore với query
    _store
        .collection('songs')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        // Xử lý dữ liệu tìm kiếm được và cập nhật _searchResults
        setState(() {
          // _searchResults = value.docs.map((doc) => doc.data()).toList();
          _searchResults = value.docs
              .map((doc) => Song.fromFirestore(doc.data(), doc.id))
              .toList();
        });
      } else {
        // Xử lý khi không tìm thấy dữ liệu
        setState(() {
          _searchResults = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Search',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onSubmitted: (value) {
                setState(() {
                  _searchText = value;
                });
                _performSearch(value);
              },
              controller: _searchController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(width: 0.8)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        BorderSide(color: Colors.greenAccent, width: 2.0)),
                hintText: 'Search sound',
                hintStyle: TextStyle(color: Color(0xff999999)),
                prefixIcon: Icon(Icons.search, color: Colors.black),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: Colors.black),
                  onPressed: () {
                    // Clear the text field
                    _searchController.clear();
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Text(
                      'No results found for "$_searchText"',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      var song = _searchResults[index];

                      return Container(
                        child: ListTile(
                          leading: Image.network(song.imageUrl,
                              width: 64, height: 64, fit: BoxFit.cover),
                          title: Text(song.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          subtitle: Text(song.author,
                              style: TextStyle(color: Colors.blueGrey)),
                          onTap: () {
                            // Chuyển sang trang phát nhạc khi chọn bài hát
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DisplayMusic(
                                  songList: _searchResults,
                                  // Truyền danh sách bài hát
                                  initialIndex:
                                      index, // Vị trí của bài hát được chọn
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
