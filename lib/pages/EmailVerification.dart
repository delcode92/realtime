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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Verifikasi Email',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Link verifikasi sudah dikirimkan ke email:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            Text(
              '${user?.email}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Silakan cek email Anda dan klik link verifikasi\nuntuk melanjutkan. Jika email verifikasi tidak masuk, \nklik tombol "Kirim Ulang Email Verifikasi dibawah.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              onPressed: () {
                user!.sendEmailVerification();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Email verifikasi telah dikirim ulang.'),
                  ),
                );
              },
              child: Text(
                'Kirim Ulang Email Verifikasi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
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
