import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:realtime/pages/login.dart';
import 'package:realtime/pages/search.dart';
import 'package:realtime/pages/updateprofil.dart';

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
  List<String> _otherUserIds = [];

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
        rooms?.forEach((key, value) {
          List<String> users = key.split('_');
          if (users.contains(currentUserUid)) {
            String otherUserId =
                users.firstWhere((userId) => userId != currentUserUid);
            _getUserDetails(otherUserId);
          }
        });
      }
    });
  }

  void _getUserDetails(String userId) {
    _database.child('users').child(userId).once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? userData =
            event.snapshot.value as Map<dynamic, dynamic>?;
        if (userData != null && userData.containsKey('nama')) {
          String nama = userData['nama'] as String;
          String profilePicture = userData['profilePicture'] as String;
          String uid = userData['uid'] as String;
          if (!_otherUserNames.contains(nama)) {
            setState(() {
              _otherUserNames.add(nama);
              _otherUserProfilePictures.add(profilePicture);
              _otherUserIds.add(uid);
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

        // Update latest message and timestamp
        _database
            .child('rooms')
            .child(roomKey)
            .orderByKey()
            .limitToLast(1)
            .once()
            .then((DatabaseEvent messageEvent) {
          if (messageEvent.snapshot.value != null) {
            Map<dynamic, dynamic>? messages =
                messageEvent.snapshot.value as Map<dynamic, dynamic>?;
            messages?.forEach((messageKey, messageData) {
              setState(() {
                _latestMessages[roomKey] = messageData['text'];
                _latestTimestamps[roomKey] = messageData['timestamp'];
              });
            });
          }
        });
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
    if (timestamp == 0) {
      return '';
    }
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
              String roomKey = '${_currentUser.uid}_${_otherUserIds[index]}';
              String lastMessage = _latestMessages.containsKey(roomKey)
                  ? _latestMessages[roomKey]
                  : '';
              int? lastTimestamp = _latestTimestamps.containsKey(roomKey)
                  ? _latestTimestamps[roomKey]
                  : 0;
              String lastMessageTime = _formatTimestamp(lastTimestamp!);
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(_otherUserProfilePictures[index]),
                ),
                title: Text(_otherUserNames[index]),
                subtitle: Text(lastMessage),
                trailing: Text(lastMessageTime),
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
