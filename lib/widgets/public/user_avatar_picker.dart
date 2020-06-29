import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserAvatarPicker extends StatefulWidget {
  UserAvatarPicker(this.imagePickFn, this.userImageURL, this.deleteUserImage);

  final void Function(File pickedImage) imagePickFn;
  final String userImageURL;
  final void Function() deleteUserImage;

  @override
  _UserAvatarPickerState createState() => _UserAvatarPickerState();
}

class _UserAvatarPickerState extends State<UserAvatarPicker> {
  File _pickedImage;
  String _userImageURL;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _userImageURL = widget.userImageURL;
  }

  void _pickImage([ImageSource source]) async {
    if (source == null) {
      setState(() {
        _pickedImage = null;
        _userImageURL = null;
      });
      widget.deleteUserImage();
    } else {
      final pickedImageFile = await _picker.getImage(
        source: source,
        imageQuality: 50,
        maxWidth: 150,
      );
      setState(() {
        _pickedImage = File(pickedImageFile.path);
      });
      widget.imagePickFn(File(pickedImageFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.userImageURL);
    print(_userImageURL);
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          backgroundImage:
              _pickedImage != null ? FileImage(_pickedImage)
                : (_userImageURL == null || _userImageURL.isEmpty) ? AssetImage('images/avatar.jpg')
                  : NetworkImage(_userImageURL),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlatButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: Icon(Icons.image),
              label: Text('Gallery'),
            ),
            FlatButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: Icon(Icons.camera_alt),
              label: Text('Camera'),
            ),
            FlatButton.icon(
              onPressed: () => _pickImage(),
              icon: Icon(Icons.delete),
              label: Text('Delete'),
            ),
          ],
        ),
      ],
    );
  }
}
