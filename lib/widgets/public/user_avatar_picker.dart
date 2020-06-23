import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserAvatarPicker extends StatefulWidget {
  UserAvatarPicker(this.imagePickFn);

  final void Function(PickedFile pickedImage) imagePickFn;

  @override
  _UserAvatarPickerState createState() => _UserAvatarPickerState();
}

class _UserAvatarPickerState extends State<UserAvatarPicker> {
  PickedFile _pickedImage;

  final ImagePicker _picker = ImagePicker();

  void _pickImage(ImageSource source) async {
    final pickedImageFile = await _picker.getImage(
      source: source,
      imageQuality: 50,
      maxWidth: 150,
    );
    setState(() {
      _pickedImage = pickedImageFile;
    });
    widget.imagePickFn(pickedImageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          backgroundImage:
              _pickedImage != null ? FileImage(File(_pickedImage.path)) : AssetImage('images/avatar.jpg'),
        ),
        FlatButton.icon(
          onPressed: () => _pickImage(ImageSource.gallery),
          icon: Icon(Icons.image),
          label: Text('Add Image'),
        ),
        FlatButton.icon(
          onPressed: () => _pickImage(ImageSource.camera),
          icon: Icon(Icons.camera_alt),
          label: Text('Add Image'),
        ),
      ],
    );
  }
}
