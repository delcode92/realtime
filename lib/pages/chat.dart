import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String nama;
  final String? profilePicture;

  ChatScreen({
    required this.roomId,
    required this.nama,
    this.profilePicture,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DatabaseReference referenceDatabase =
      FirebaseDatabase.instance.reference().child('rooms');
  void initState() {
    super.initState();
    _initializeDownloader();
  }

  Future<void> _initializeDownloader() async {}

  TextEditingController messageController = TextEditingController();

  IconData _getFileTypeIcon(String? fileName) {
    if (fileName == null) return Icons.insert_drive_file;
    String ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.article;
      default:
        return Icons.insert_drive_file;
    }
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
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.profilePicture != null
                  ? NetworkImage(widget.profilePicture!)
                  : null,
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              widget.nama,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: referenceDatabase
                  .child(widget.roomId)
                  .orderByChild('timestamp')
                  .onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  Map<dynamic, dynamic>? map =
                      (snapshot.data!.snapshot.value as Map?);
                  List<dynamic> messages = [];
                  if (map != null) {
                    map.forEach((key, value) {
                      messages.add(value);
                    });
                  }
                  messages
                      .sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index];
                      bool isSentByCurrentUser = (message['sender'] ==
                          FirebaseAuth.instance.currentUser!.uid);

                      return Column(
                        crossAxisAlignment: isSentByCurrentUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (message['text'] != null)
                            Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSentByCurrentUser
                                    ? Colors.blue
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['text'],
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    _formatTimestamp(message['timestamp']),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 8),
                                  ),
                                ],
                              ),
                            ),
                          if (message['imageUrl'] != null)
                            Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSentByCurrentUser
                                    ? Colors.blue
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.network(
                                          message['imageUrl'],
                                          fit: BoxFit.cover,
                                          color: isSentByCurrentUser
                                              ? null
                                              : Color.fromRGBO(
                                                  255, 255, 255, 0.5),
                                          colorBlendMode: isSentByCurrentUser
                                              ? BlendMode.dstATop
                                              : BlendMode.srcOver,
                                        ),
                                      ),
                                      if (!isSentByCurrentUser)
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              width: 35,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.transparent,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.download,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    _formatTimestamp(message['timestamp']),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (message['fileUrl'] != null)
                            Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              padding: EdgeInsets.all(10),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7,
                              ),
                              decoration: BoxDecoration(
                                color: isSentByCurrentUser
                                    ? Colors.blue
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _getFileTypeIcon(message['fileName']),
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${message['fileName']}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'Ukuran: ${_formatFileSize(message['fileSize'])}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isSentByCurrentUser)
                                        GestureDetector(
                                          onTap: () async {
                                            if (!(await _isFileDownloaded(
                                                message['fileName']))) {
                                              setState(() {
                                                message['downloading'] = true;
                                              });
                                              _downloadFile(message['fileUrl'],
                                                      message['fileName'])
                                                  .then((_) {
                                                setState(() {
                                                  message['downloading'] =
                                                      false;
                                                });
                                              });
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'File sudah diunduh.'),
                                                ),
                                              );
                                            }
                                          },
                                          child: Container(
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.transparent,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            child: Center(
                                              child: message['downloading'] ==
                                                      true
                                                  ? CircularProgressIndicator()
                                                  : FutureBuilder<bool>(
                                                      future: _isFileDownloaded(
                                                          message['fileName']),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return CircularProgressIndicator();
                                                        } else {
                                                          if (snapshot
                                                                  .hasData &&
                                                              snapshot.data!) {
                                                            return Icon(
                                                              Icons.done,
                                                              color:
                                                                  Colors.white,
                                                            );
                                                          } else {
                                                            return Icon(
                                                              Icons.download,
                                                              color:
                                                                  Colors.white,
                                                            );
                                                          }
                                                        }
                                                      },
                                                    ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    _formatTimestamp(message['timestamp']),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text('Belum ada pesan'),
                  );
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.photo_camera_sharp,
                        color: Colors.grey,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 35,
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                              hintText: "Ketik Pesan",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Row(
                        children: [
                          PopupMenuButton(
                            icon: Image.asset('assets/icons/clip.png'),
                            onSelected: (value) async {
                              if (value == 'image') {
                                final imagePicker = ImagePicker();
                                final pickedFile = await imagePicker.pickImage(
                                    source: ImageSource.gallery);
                                if (pickedFile != null) {
                                  final imageFile = File(pickedFile.path);
                                  final imageRef = FirebaseStorage.instance
                                      .ref()
                                      .child('images')
                                      .child(
                                          '${DateTime.now().millisecondsSinceEpoch}.jpg');
                                  await imageRef.putFile(imageFile);
                                  final imageUrl =
                                      await imageRef.getDownloadURL();

                                  _sendMessage('', imageUrl: imageUrl);
                                }
                              }
                              if (value == 'file') {
                                final result = await FilePicker.platform
                                    .pickFiles(allowMultiple: false);
                                if (result != null) {
                                  final filePath = result.files.single.path!;
                                  final file = File(filePath);
                                  if (await file.exists()) {
                                    final fileName = result.files.single.name;
                                    final fileRef = FirebaseStorage.instance
                                        .ref()
                                        .child('files')
                                        .child(
                                            '${DateTime.now().millisecondsSinceEpoch}_$fileName');

                                    await fileRef.putFile(file);
                                    final fileUrl =
                                        await fileRef.getDownloadURL();
                                    final fileFileSize = await file.length();
                                    _sendMessage('',
                                        fileUrl: fileUrl,
                                        fileName: fileName,
                                        fileSize: fileFileSize);
                                  } else {
                                    print('File tidak ditemukan.');
                                  }
                                }
                              }
                            },
                            offset: Offset(0, 200),
                            itemBuilder: (BuildContext bc) {
                              return [
                                PopupMenuItem(
                                  value: 'image',
                                  child: Row(
                                    children: [
                                      Icon(Icons.image),
                                      SizedBox(width: 10),
                                      Text('Pilih Gambar'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'file',
                                  child: Row(
                                    children: [
                                      Icon(Icons.file_copy_outlined),
                                      SizedBox(width: 10),
                                      Text('Pilih File'),
                                    ],
                                  ),
                                ),
                              ];
                            },
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.03,
                          ),
                          Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.blue),
                            child: Center(
                              child: IconButton(
                                icon: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                                iconSize: 20,
                                onPressed: () {
                                  if (messageController.text.isNotEmpty) {
                                    _sendMessage(messageController.text);
                                    messageController.clear();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text,
      {String? imageUrl, String? fileUrl, String? fileName, int? fileSize}) {
    if (text.isNotEmpty || imageUrl != null || fileUrl != null) {
      Map<String, dynamic> messageData = {
        'sender': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      if (text.isNotEmpty) {
        messageData['text'] = text;
      }

      if (imageUrl != null) {
        messageData['imageUrl'] = imageUrl;
      }

      if (fileUrl != null) {
        messageData['fileUrl'] = fileUrl;
        messageData['fileName'] = fileName;
        messageData['fileSize'] = fileSize;
      }

      referenceDatabase.child(widget.roomId).push().set(messageData);
    }
  }

  String _formatTimestamp(int timestamp) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var timeFormat = DateFormat('HH:mm').format(dateTime);
    return timeFormat;
  }

  String _formatFileSize(int fileSize) {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  Future<void> _downloadFile(String fileUrl, String fileName) async {
    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        final externalDir = await getExternalStorageDirectory();
        final savedDir = Directory('${externalDir!.path}/DisApp/Documents');
        bool hasExisted = await savedDir.exists();
        if (!hasExisted) {
          await savedDir.create(recursive: true);
        }
        await FlutterDownloader.enqueue(
          url: fileUrl,
          savedDir: savedDir.path,
          fileName: fileName,
          showNotification: true,
          openFileFromNotification: true,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Izin penyimpanan ditolak.'),
          ),
        );
      }
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  Future<bool> _isFileDownloaded(String fileName) async {
    final externalDir = await getExternalStorageDirectory();
    final file = File('${externalDir!.path}/DisApp/Documents/$fileName');
    return await file.exists();
  }
}
