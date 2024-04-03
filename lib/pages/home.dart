import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:realtime/pages/login.dart';
import 'package:realtime/pages/search.dart';

class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  TextEditingController emailcontroller = TextEditingController();

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "DisApp",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(),
                ),
              );
            },
          ),
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onSelected: (value) {
              if (value == 1) {
                // Handle Profile option
              } else if (value == 2) {
                // Handle Log Out option
                _signOut();
              }
            },
            itemBuilder: (BuildContext bc) {
              return [
                PopupMenuItem(
                  child: Text("Profil"),
                  value: 1,
                ),
                PopupMenuItem(
                  child: Text("Log Out"),
                  value: 2,
                ),
              ];
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: (() {
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => Kontak_Page()));
                }),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/chat.png"),
                            fit: BoxFit.cover)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
