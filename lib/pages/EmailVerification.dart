import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:realtime/pages/fillprofil.dart';

class veritifikasi extends StatefulWidget {
  const veritifikasi({super.key});

  @override
  State<veritifikasi> createState() => _veritifikasiState();
}

class _veritifikasiState extends State<veritifikasi> {
  final auth = FirebaseAuth.instance;
  User? user;
  Timer? timer;

  @override
  void initState() {
    user = auth.currentUser!;
    user!.sendEmailVerification();
    print('email terkirim $user.email');
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        chekemail();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'veritifikasi ${user?.email}',
        ),
      ),
    );
  }

  Future<void> chekemail() async {
    user = auth.currentUser!;
    await user?.reload();
    if (user!.emailVerified) {
      timer?.cancel();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => fillProfile()));
    }
  }
}
