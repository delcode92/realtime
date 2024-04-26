// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:realtime/pages/EmailVerification.dart';

class signup extends StatefulWidget {
  const signup({super.key});

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _cPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void checkvalues() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String cpassword = _cPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || cpassword.isEmpty) {
      print("Please fill all the fields");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Masi ada yang kosong'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (password.length < 6) {
      print("Password must be at least 6 characters long");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password minimal 6 karakter'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (password != cpassword) {
      print("Passwords do not match");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('passwods tidak sama'),
          backgroundColor: Colors.red,
        ),
      );
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

      if (credential != null) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => veritifikasi()));

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          DatabaseReference usersRef =
              FirebaseDatabase.instance.reference().child('users');
          usersRef.child(user.uid).set({
            'email': email,
            'uid': user.uid,
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('email sudah terdaftar.'),
            backgroundColor: Colors.blue,
          ),
        );
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
                    controller: _passwordController,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: _cPasswordController,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                      border: OutlineInputBorder(),
                      labelText: "Confirm Password",
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        child: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
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
