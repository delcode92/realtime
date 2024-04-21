/*
setelah signup via gmail , isi profile utk aplikasi
*/ 

import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realtime/pages/home.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({Key? key});

  @override
  _CompleteProfileState createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
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

  // pop up select file after cliked user pic 
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

    if (nama.isEmpty || telepon.isEmpty || imageFile == null) {
      print("Please fill all the fields");
    } else {
      log("Uploading data..");
      uploadData();
    }
  }

  void uploadData() async {
    if (imageFile == null) {
      print("Please select a profile picture.");
      return;
    }

    String nama = namaController.text.trim();
    String telepon = teleponController.text.trim();

    // HARUS DIUPDATE
    // nama file ganti jadi id account
    // Utk solusi masalah replace/update gambar profile
    
    // get user current user id: Tapi cek dulu tipe datanya, apakah bisa digabung dengan string ?
    // FirebaseAuth.instance.currentUser;
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";

  // upload to fire storage
    Reference ref =
        FirebaseStorage.instance.ref("profilepictures").child(fileName);
    UploadTask uploadTask = ref.putFile(imageFile!);
    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;

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
              CupertinoButton(
                onPressed: () {
                  showPhotoOptions();
                },
                padding: EdgeInsets.all(0),
                child: CircleAvatar(
                  radius: 60,
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
              ),
              SizedBox(height: 15),
              Text(
                "Nama",
                style: TextStyle(fontSize: 18),
              ),
              TextField(
                controller: namaController,
                decoration: InputDecoration(
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
