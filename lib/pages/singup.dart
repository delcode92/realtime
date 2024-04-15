// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:realtime/pages/fillprofil.dart';

class signup extends StatefulWidget {
  const signup({super.key});

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _cPasswordController = TextEditingController();

  void checkvalues() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String cpassword = _cPasswordController.text.trim();

    if (email == "" || password == "" || cpassword == "") {
      print("Please fill all the fields");
    } else if (password != cpassword) {
      print("Passwords do not match");
    } else {
      signup(email, password);
    }
  }

  void signup(String email, String password) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If user registration is successful
      if (credential != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          DatabaseReference usersRef =
              FirebaseDatabase.instance.reference().child('users');
          usersRef.child(user.uid).set({
            'email': email,
            'uid': user.uid,
          });

          // Navigate to the home page after successful signup
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CompleteProfile()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(25),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "DisApp",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                        border: OutlineInputBorder(),
                        labelText: "Email"),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    obscureText: true,
                    controller: _passwordController,
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                        border: OutlineInputBorder(),
                        labelText: "Password"),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    obscureText: true,
                    controller: _cPasswordController,
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                        border: OutlineInputBorder(),
                        labelText: "Confirm Password"),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            checkvalues();
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(double.infinity, 50),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have account?",
                        ),
                        CupertinoButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Log in",
                              style: TextStyle(color: Colors.blue),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
