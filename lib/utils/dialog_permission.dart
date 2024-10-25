import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music/utils/user_preferences.dart';

class DialogPermission {
  Future<void> DialogChangeNameUser(BuildContext context) async {
    TextEditingController _nameController = TextEditingController();

    String name = await UserPreferences.getYourName();
    _nameController.text = name;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xff333333),
          title: const Text('Change your name',
              style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Your name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
          ),
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
                changeNameUser(_nameController.text); // Thực hiện đổi tên
              },
              child: const Text('Yes', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  // Hàm thay đổi tên người dùng trong Firestore
  Future<void> changeNameUser(String name) async {
    final FirebaseFirestore _store = FirebaseFirestore.instance;
    final userFuture = await UserPreferences.getUserID();
    var userID = userFuture;

    _store.collection('users').doc(userID).update({
      'name': name,
    });
    _store
        .collection('songs')
        .where('userId', isEqualTo: userID)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        _store.collection('songs').doc(element.id).update({
          'author': name,
        });
      });
    });
  }

  // change password
  Future<void> DialogChangePassword(BuildContext context) async {
    TextEditingController _passwordController = TextEditingController();
    TextEditingController _newPasswordController = TextEditingController();
    TextEditingController _confirmPasswordController = TextEditingController();

    String messageError = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {


            return AlertDialog(
              backgroundColor: const Color(0xff333333),
              title: const Text('Change password', style: TextStyle(color: Colors.white)),
              content: SizedBox(
                height: 250,
                width: double.infinity,
                child: Column(
                  children: [
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Current password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _newPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'New password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    if (messageError != '')
                      Expanded(
                        child: Text('Error: *$messageError', style: TextStyle(color: Colors.redAccent , fontSize: 16)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Đóng hộp thoại nếu hủy
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
                ),
                TextButton(
                  onPressed: () async {
                    String result = await changePassword(
                      _passwordController.text,
                      _newPasswordController.text,
                      _confirmPasswordController.text,
                    );
                    setState(() {
                      messageError = result;
                    });
                  },
                  child: const Text('Yes', style: TextStyle(color: Colors.green)),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // Hàm thay đổi mật khẩu người dùng trong Firestore
  Future<String> changePassword(String password, String newPassword, String confirmPassword) async {
    final FirebaseFirestore _store = FirebaseFirestore.instance;
    final userFuture = await UserPreferences.getUserID();
    var userID = userFuture;

    if(password == '' || newPassword == '' || confirmPassword == '') {
      return 'Please fill in all fields';
    } else {
      if (newPassword != confirmPassword) {
        return 'New password and confirm password do not match';
      } else {
        var userDoc = await _store.collection('users').doc(userID).get();
        if (userDoc.data()!['password'] != password) {
          return 'Current password is incorrect';
        } else {
          await _store.collection('users').doc(userID).update({
            'password': newPassword,
          });
          return '';
        }
      }
    }


  }
}

