// // void login(String email, String password) async {
//   //   UserCredential? credential;
//   //   try {
//   //     credential = await FirebaseAuth.instance
//   //         .signInWithEmailAndPassword(email: email, password: password);
//   //   } on FirebaseAuthException catch (ex) {
//   //     print(ex.message.toString());
//   //   }
//   //   if (credential != null) {
//   //     String uid = credential.user!.uid;

//   //     DocumentSnapshot userData =
//   //         await FirebaseFirestore.instance.collection('users').doc(uid).get();
//   //     if (userData.exists && userData.data() != null) {
//   //       UserModel userModel =
//   //           UserModel.fromMap(userData.data() as Map<String, dynamic>);
//   //       print("Log in successful!");
//   //     } else {
//   //       print("User data not found or empty.");
//   //     }
//   //   }
//   // }



//   // void signup(String email, String password) async {
//   //   UserCredential? credential;
//   //   try {
//   //     credential = await FirebaseAuth.instance
//   //         .createUserWithEmailAndPassword(email: email, password: password);
//   //   } on FirebaseAuthException catch (ex) {
//   //     print(ex.code.toString());
//   //   }
//   // if (credential != null) {
//   //   String uid = credential.user!.uid;
//   //   UserModel newuser =
//   //       UserModel(uid: uid, email: email, fullname: "", profilepic: "");
//   //   await FirebaseFirestore.instance
//   //       .collection("user")
//   //       .doc(uid)
//   //       .set(newuser.toMap())
//   //       .then((value) {
//   //     print("New user created!");
//   //   });
//   // }
//   // }

//    Column(
//                 children: [
//                   Container(
//                     height: MediaQuery.of(context).size.height * 0.08,
//                     color: Colors.blue,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "DisApp",
//                             style: TextStyle(color: Colors.white, fontSize: 25),
//                           ),
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.search,
//                                 color: Colors.white,
//                                 size: 30,
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                   //isi list pengguna
//                   Expanded(
//                     child: ListView(
//                       children: [
//                         GestureDetector(
//                           onTap: (() {}),
//                           child: Container(
//                             height: 100,
//                             child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Container(
//                                     child: Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 15.0),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Row(
//                                             children: [
//                                               Container(
//                                                 width: 45,
//                                                 height: 45,
//                                                 decoration: BoxDecoration(
//                                                     shape: BoxShape.circle,
//                                                     image: DecorationImage(
//                                                         image: AssetImage(
//                                                             "assets/images/tambah.png"),
//                                                         fit: BoxFit.cover)),
//                                               ),
//                                               SizedBox(
//                                                 width: 25,
//                                               ),
//                                               Text("kontak baru")
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   )
//                                 ]),
//                           ),
//                         ),
//                         for (int i = 0; i < 50; i++)
//                           GestureDetector(
//                             onTap: (() {}),
//                             child: Container(
//                               height: 100,
//                               child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Container(
//                                       child: Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 15.0),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Row(
//                                               children: [
//                                                 Container(
//                                                   width: 45,
//                                                   height: 45,
//                                                   decoration: BoxDecoration(
//                                                       shape: BoxShape.circle,
//                                                       image: DecorationImage(
//                                                           image: AssetImage(
//                                                               "assets/images/profil.png"),
//                                                           fit: BoxFit.cover)),
//                                                 ),
//                                                 SizedBox(
//                                                   width: 25,
//                                                 ),
//                                                 Text("nama asli")
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     )
//                                   ]),
//                             ),
//                           ),
//                       ],
//                     ),
//                   )
//                 ],
//               ),