import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageUpload extends StatefulWidget {
  const ImageUpload({Key? key}) : super(key: key);

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  late File file;
  ImagePicker image = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Upload'),),
      body: Center(

          child: ListView(
              children: [
                Column(
                    children: <Widget>[
                      IconButton(
                        // padding: const EdgeInsets.all(15),
                        icon: const Icon(Icons.camera_alt),
                        color: Colors.white,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Please choose"),
                              content: const Text("From:"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () async {
                                    // getCam();
                                    PermissionStatus cameraStatus = await Permission.camera.request();
                                    if (cameraStatus == PermissionStatus.granted) {
                                      getCam(ImageSource.camera);
                                    } else if (cameraStatus == PermissionStatus.denied) {
                                      return ;
                                    }

                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    child: const Text("Camera"),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    // getGall();
                                    PermissionStatus cameraStatus = await Permission.storage.request();
                                    if (cameraStatus == PermissionStatus.granted) {
                                      getGall(ImageSource.gallery);
                                    } else if (cameraStatus == PermissionStatus.denied) {
                                      return;
                                    }

                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    child: const Text("Gallery"),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    child: const Text("Cancel"),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          uploadImage(file);
                        }, child: Text('Upload'),
                      ),
                    ]
                ),
              ]
          )
    )
    );
  }

  uploadImage(File file) async {
    var request = http.MultipartRequest(
        "POST", Uri.parse("https://63c95a0e320a0c4c9546afb1.mockapi.io/api/images_share"));

    var picture = http.MultipartFile.fromBytes('image',
        (await rootBundle.load('assets/testimage.png')).buffer.asUint8List(),
        filename: 'testimage.png');

    request.files.add(picture);

    var response = await request.send();

    var responseData = await response.stream.toBytes();

    var result = String.fromCharCodes(responseData);

    print(result);
  }

  getCam(ImageSource source) async {
    // ignore: deprecated_member_use
    var img = await image.getImage(source: ImageSource.camera);
    setState(() {
      file = File(img!.path);
    });
  }

  getGall(ImageSource source) async {
    // ignore: deprecated_member_use
    var img = await image.getImage(source: ImageSource.gallery);
    setState(() {
      file = File(img!.path);
    });
  }
}

