import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:realtime/pages/chat.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.reference().child('users');

  // user ? --> string ???
  User? currentUser = FirebaseAuth.instance.currentUser;

  Stream<DatabaseEvent> searchUserBynama(String nama) {
    return _userRef
        .orderByChild('nama')
        .startAt(nama)
        .endAt(nama + "\uf8ff")
        .onValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Image.asset('assets/icons/back.png'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Search",
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: searchController.text.isNotEmpty
                    ? StreamBuilder<DatabaseEvent>(
                        stream: searchUserBynama(searchController.text.trim()),
                        builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data!.snapshot.value != null) {
                            Map<dynamic, dynamic>? userData =
                                (snapshot.data!.snapshot.value as Map?);
                            List<Widget> usersList = [];
                            if (userData != null) {
                              userData.forEach((key, value) {
                                if (value['uid'] != currentUser!.uid) {
                                  usersList.add(
                                    GestureDetector(

                                      // masuk ke laman chat, ketika tap profile user lain
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) {
                                            return ChatScreen(
                                              roomId: generateRoomId(
                                                  currentUser!.uid,
                                                  value['uid']),
                                              nama: value['nama'],
                                              profilePicture:
                                                  value['profilePicture'],
                                            );
                                          }),
                                        );
                                      },
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              value['profilePicture'] ?? ''),
                                        ),
                                        title: Text(value['nama']),
                                        // title: Text(value['hp']),
                                        subtitle: Text(value['email']),
                                      ),
                                    ),
                                  );
                                }
                              });
                            }
                            return ListView(
                              children: usersList,
                            );
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      )
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String generateRoomId(String userId1, String userId2) {
    List<String> participants = [userId1, userId2];
    participants.sort();
    String roomId = participants.join('_');
    return roomId;
  }
}
