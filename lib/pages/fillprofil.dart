import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realtime/pages/home.dart';

class fillProfile extends StatefulWidget {
  const fillProfile({Key? key});

  @override
  _fillProfileState createState() => _fillProfileState();
}

class _fillProfileState extends State<fillProfile> {
  File? imageFile;
  TextEditingController namaController = TextEditingController();
  TextEditingController teleponController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    final imageCropper = ImageCropper();

    CroppedFile? croppedImage = await imageCropper.cropImage(
      sourcePath: file.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      compressQuality: 20,
    );

    if (croppedImage != null) {
      File croppedFile = File(croppedImage.path);

      setState(() {
        imageFile = croppedFile;
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Upload Profile Picture"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.gallery);
                },
                leading: Icon(Icons.photo_album),
                title: Text("Select from Gallery"),
              ),
            ],
          ),
        );
      },
    );
  }

  void checkValues() {
    String nama = namaController.text.trim();
    String telepon = teleponController.text.trim();

    if (nama.isEmpty || telepon.isEmpty) {
      print("Please fill all the fields");
    } else {
      log("Uploading data..");
      uploadData();
    }
  }

  void uploadData() async {
    String nama = namaController.text.trim();
    String telepon = teleponController.text.trim();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;

      String imageUrl = '';
      if (imageFile != null) {
        String fileName = '$uid.jpg';

        Reference ref =
            FirebaseStorage.instance.ref("profilePicture").child(fileName);
        UploadTask uploadTask = ref.putFile(imageFile!);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      DatabaseReference usersRef =
          FirebaseDatabase.instance.reference().child('users');
      usersRef.child(uid).update({
        'nama': nama,
        'telepon': telepon,
        'profilePicture': imageUrl,
      });

      print("Profile data uploaded!");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return Home_Page();
        }),
      );
    } else {
      print("Error: User not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Isi Profile"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: ListView(
            children: [
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            (imageFile != null) ? FileImage(imageFile!) : null,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (imageFile == null)
                              Icon(
                                Icons.person,
                                size: 100,
                                color: Colors.white,
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            showPhotoOptions();
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                            child: Icon(Icons.camera_alt,
                                color: Colors.white, size: 30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                "Nama",
                style: TextStyle(fontSize: 18),
              ),
              TextField(
                controller: namaController,
                decoration: InputDecoration(
                  hintText: 'Isi nama lengkap anda',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Telepon",
                style: TextStyle(fontSize: 18),
              ),
              TextField(
                controller: teleponController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '08xxxxxxxxxx',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        child: ElevatedButton(
          onPressed: () {
            checkValues();
          },
          style: ElevatedButton.styleFrom(
            fixedSize: Size(double.infinity, 50),
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            "Simpan",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
