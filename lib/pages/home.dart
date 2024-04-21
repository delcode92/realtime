import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:realtime/pages/login.dart';
import 'package:realtime/pages/search.dart';
import 'package:realtime/pages/uprofil.dart';

class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  late User _currentUser;
  List<String> _otherUserNames = [];
  List<String> _otherUserProfilePictures = [];
  Map<String, dynamic> _latestMessages = {};
  Map<String, int> _latestTimestamps = {};

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    _currentUser = FirebaseAuth.instance.currentUser!;
    _checkRooms();
    if (_currentUser != null) {
      _listenForNewRooms();
      _listenForRemovedRooms();
    }
  }

  void _checkRooms() {
    String currentUserUid = _currentUser.uid;

    _database.child('rooms').once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? rooms =
            event.snapshot.value as Map<dynamic, dynamic>?;

        // format IduserLain_MyUserId atau MyUserId_IduserLain

        rooms?.forEach((key, value) {
          // misal string = "hello world"
          // "hello" atau "world" ?
          List<String> users = key.split('_');

          // cek dalam string user apakah mengandung id kita sekarang ?
          if (users.contains(currentUserUid)) {
            String otherUserId =
                users.firstWhere((userId) => userId != currentUserUid);

            _getUserDetails(otherUserId);
          }
        });
      }
    });
  }

/*
room
|
-----> itxJ7TkfU9YRZm1NerLoCmA0XBf2_ogs60gV8BtWshphkjXAQvPZlHQy2
      |
      ---> ambil semua key yg berada didalam `itxJ7TkfU9YRZm1NerLoCmA0XBf2_ogs60gV8BtWshphkjXAQvPZlHQy2`, kemudian simpan dalam list/array
          ["-NvbXWl2t2hDKhJH-WbK", ....., -Nvtmy8UBH2nodxRd62g]
          ambil index terakhir dari list/array tsb
          ==> cek apakah ada key filename, klo gk ada berarti text, tapi jika ada key `filename` --> cek lagi extensi filenya, berupa file gambar atau yg lainnya
          ==> last_message = ["room"]["itxJ7TkfU9YRZm1NerLoCmA0XBf2_ogs60gV8BtWshphkjXAQvPZlHQy2"]["Nvtmy8UBH2nodxRd62g"]["text"]
*/


  // UBAH key name jadi nama
  // userId --> user id pengguna lain

  /*

  // jalanakan ketika listile di tap ---> kirim 2 argumen userId1, userId2

1.String generateRoomId(String userId1, String userId2) {
    List<String> participants = [userId1, userId2];
    participants.sort();
    String roomId = participants.join('_');
    return roomId;
  }

 2. setelah jalankan generateRoomId() --> manggil ChatScreen()

  */

  void _getUserDetails(String userId) {
    _database.child('users').child(userId).once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? userData =
            event.snapshot.value as Map<dynamic, dynamic>?;
        if (userData != null && userData.containsKey('nama')) {
          // GET DATA DARI RELATIME DB
          String nama = userData['nama'] as String;
          String profilePicture = userData['profilePicture'] as String;

          print("cek=> $nama");
          print("cek=> $profilePicture");

          if (!_otherUserNames.contains(nama)) {
            setState(() {
              // tambahakan list user ke array _otherUserNames
              _otherUserNames.add(userData['name'] as String);
              _otherUserProfilePictures.add(profilePicture);
            });
          }
        }
      }
    });
  }

  void _listenForNewRooms() {
    _database.child('rooms').onChildAdded.listen((event) {
      String currentUserUid = _currentUser.uid;
      String roomKey = event.snapshot.key!;
      Map<dynamic, dynamic> roomData =
          event.snapshot.value as Map<dynamic, dynamic>;

      List<String> users = roomKey.split('_');
      if (users.contains(currentUserUid)) {
        String otherUserId =
            users.firstWhere((userId) => userId != currentUserUid);
        _getUserDetails(otherUserId);
      }
    });
  }

  void _listenForRemovedRooms() {
    _database.child('rooms').onChildRemoved.listen((event) {
      String removedRoomKey = event.snapshot.key!;
      List<String> removedUsers = removedRoomKey.split('_');
      String currentUserUid = _currentUser.uid;

      if (removedUsers.contains(currentUserUid)) {
        setState(() {
          _otherUserNames.clear();
          _otherUserProfilePictures.clear();

          _checkRooms();
        });
      }
    });
  }

  String _formatTimestamp(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formattedTime = DateFormat('HH:mm').format(dateTime);
    return formattedTime;
  }

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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => uprofil_page()));
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
      body: Stack(
        children: [
          ListView.builder(
            itemCount: _otherUserNames.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(_otherUserProfilePictures[index]),
                ),
                title: Text(_otherUserNames[index]),
              );
            },
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
    );
  }
}
