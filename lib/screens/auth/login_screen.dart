import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music/screens/auth/register_screen.dart';
import 'package:music/screens/menu/navigation_menu.dart';
import 'package:music/utils/user_preferences.dart';
import 'package:rive/rive.dart' as rive;

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String animationURL;
  rive.Artboard? _teddyArtboard;
  rive.SMITrigger? successTrigger, failTrigger;
  rive.SMIBool? isHandsUp, isChecking;
  rive.SMINumber? numLook;

  rive.StateMachineController? stateMachineController;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseFirestore _store = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    animationURL = 'assets/login_riv.riv';
    rootBundle.load(animationURL).then((data) {
      final file = rive.RiveFile.import(data);
      final artboard = file.mainArtboard;

      stateMachineController =
          rive.StateMachineController.fromArtboard(artboard, "Login Machine");
      if (stateMachineController != null) {
        artboard.addController(stateMachineController!);
        stateMachineController!.inputs.forEach((e) {
          if (e.name == "trigSuccess") {
            successTrigger = e as rive.SMITrigger;
          } else if (e.name == "trigFail") {
            failTrigger = e as rive.SMITrigger;
          } else if (e.name == "isHandsUp") {
            isHandsUp = e as rive.SMIBool;
          } else if (e.name == "isChecking") {
            isChecking = e as rive.SMIBool;
          } else if (e.name == "numLook") {
            numLook = e as rive.SMINumber;
          }
        });
      }
      setState(() {
        _teddyArtboard = artboard;
      });
    });

    checkStatusLogin();
  }

  void handsOnTheEyes() {
    isHandsUp?.change(true);
  }

  void lookOnTheField() {
    isHandsUp?.change(false);
    isChecking?.change(true);
    numLook?.change(0);
  }

  void moveEyesBalls(val) {
    numLook?.change(val.length.toDouble());
  }

  void resetAnimation() {
    isHandsUp?.change(false);
    isChecking?.change(false);
  }

  Future<void> checkStatusLogin() async {
    bool isLoggedIn =
        await UserPreferences.isLogin(); // Chờ kết quả từ SharedPreferences

    if (isLoggedIn) {
      Navigator.pushNamed(context, NavigationMenu.id);
      print('Login');
    } else {
      print('Not login');
    }
  }

  Future<void> _signIn() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username == '' || password == '') {
      failTrigger?.fire();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields!'),
        ),
      );
      return;
    }

    try {
      // cho animate
      resetAnimation();

      final user = await _store
          .collection('users')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .get();

      if (user.docs.isNotEmpty) {
        await UserPreferences.saveUser(username, password);
        UserPreferences.getYourName().then((name) {
          print(name);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successfully'),
          ),
        );
        successTrigger?.fire();
        // Đợi 1 giây để hoàn thành animation
        await Future.delayed(const Duration(seconds: 2));

        Navigator.pushNamed(context, NavigationMenu.id);
      } else {
        failTrigger?.fire();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed!'),
          ),
        );
      }
    } catch (e) {
      failTrigger?.fire();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD6E2EA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                child: Hero(
                    tag: 'logo',
                    child: Image.asset('assets/logo.png',
                        width: 100, height: 100)),
              ),
              Text('Login To Have\n a Better Experience!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 250,
                child: _teddyArtboard != null
                    ? rive.Rive(artboard: _teddyArtboard!, fit: BoxFit.contain)
                    : const SizedBox
                        .shrink(), // Hoặc bạn có thể đặt một widget thay thế khác
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      onTap: lookOnTheField,
                      onChanged: moveEyesBalls,
                      controller: _usernameController,
                      // change color text field
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[300],
                        labelText: 'User name',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide:
                              BorderSide(color: Colors.lightGreen, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Color(0), width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      onTap: handsOnTheEyes,
                      controller: _passwordController,
                      style: TextStyle(color: Colors.black),
                      obscureText: true,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[300],
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: Colors.lightGreen, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Color(0), width: 2.0),
                          )),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Forgot password?',
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, RegisterScreen.id);
                          },
                          child: const Text(
                            'Sign up',
                            style:
                                TextStyle(color: Colors.blueGrey, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _signIn,
                      child: const Text('Login',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
