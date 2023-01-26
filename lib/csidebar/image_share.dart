import 'package:finalproject/csidebar/image_upload.dart';
import 'package:flutter/material.dart';


class ImageShare extends StatefulWidget {
  const ImageShare({Key? key}) : super(key: key);

  @override
  State<ImageShare> createState() => _ImageShareState();
}

class _ImageShareState extends State<ImageShare> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Sharing"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ImageUpload())
          );
        },
        child: const Icon(Icons.image_outlined),
      ),
    );
  }
}
