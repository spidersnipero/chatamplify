import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Userimagepicker extends StatefulWidget {
  const Userimagepicker({super.key, required this.imagePickFn});
  final void Function(File pickedImage) imagePickFn;

  @override
  State<Userimagepicker> createState() => _UserimagepickerState();
}

class _UserimagepickerState extends State<Userimagepicker> {
  File? _pickedImageFile;
  void pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
      maxHeight: 150,
    );
    setState(() {
      _pickedImageFile = File(pickedImage!.path);
    });
    widget.imagePickFn(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
        ),
        TextButton.icon(
          onPressed: () {
            pickImage();
          },
          icon: const Icon(Icons.image),
          label: const Text("Add Image"),
        ),
      ],
    );
  }
}
