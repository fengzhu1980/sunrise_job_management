import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPicker extends StatefulWidget {
  PhotoPicker(this.imagePickFn, this.imageURL, this.deleteImage,
      [this.imageIndex]);

  final void Function(File pickedImage, [int imageIndex]) imagePickFn;
  final String imageURL;
  final void Function([int imageIndex]) deleteImage;
  final int imageIndex;

  @override
  _PhotoPickerState createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  File _pickedImage;
  String _imageURL;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imageURL = widget.imageURL;
  }

  void _pickImage([ImageSource source]) async {
    print('source: $source');
    if (source == null) {
      setState(() {
        _pickedImage = null;
        _imageURL = null;
      });
      if (widget.imageIndex != null) {
        widget.deleteImage(widget.imageIndex);
      } else {
        widget.deleteImage();
      }
    } else {
      final pickedImageFile = await _picker.getImage(
        source: source,
        imageQuality: 100,
        maxWidth: 800,
      );
      print('pickedImageFile: ${pickedImageFile}');
      if (pickedImageFile != null) {
        print('pickedImageFile: ${pickedImageFile.path}');
        setState(() {
          _pickedImage = File(pickedImageFile.path);
        });
        if (widget.imageIndex != null) {
          widget.imagePickFn(File(pickedImageFile.path), widget.imageIndex);
        } else {
          widget.imagePickFn(File(pickedImageFile.path));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildImageWidget(),
        _buildBtnsWidget(),
      ],
    );
  }

  Widget _buildImageWidget() {
    print('_imageURL: $_imageURL');
    print('_pickedImage: $_pickedImage');
    if (_pickedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        child: Image.file(
          _pickedImage,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else if (_imageURL != null) {
      if (_imageURL.isNotEmpty) {
        return ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          child: Image.network(
            _imageURL,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      }
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        color: Colors.grey[300],
      ),
      height: 100,
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Please select a photo',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBtnsWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
        color: Colors.grey[200],
      ),
      child: Row(
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
    );
  }
}
