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
  TextEditingController fullNameController = TextEditingController();
  TextEditingController NomorController = TextEditingController();

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
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.camera);
                },
                leading: Icon(Icons.camera_alt),
                title: Text("Take a photo"),
              ),
            ],
          ),
        );
      },
    );
  }

  void checkValues() {
    String fullname = fullNameController.text.trim();
    String intansi = NomorController.text.trim();

    if (fullname.isEmpty || intansi.isEmpty || imageFile == null) {
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

    String fullname = fullNameController.text.trim();
    String intansi = NomorController.text.trim();

    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";

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
        'fullName': fullname,
        'intansi': intansi,
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
        title: Text("Complete Profile"),
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
                  backgroundImage:
                      (imageFile != null) ? FileImage(imageFile!) : null,
                  child: (imageFile == null)
                      ? Icon(
                          Icons.person,
                          size: 60,
                        )
                      : null,
                ),
              ),
              SizedBox(height: 15),
              Text(
                "Nama",
                style: TextStyle(fontSize: 18),
              ),
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Nomor Hp",
                style: TextStyle(fontSize: 18),
              ),
              TextField(
                controller: NomorController,
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
