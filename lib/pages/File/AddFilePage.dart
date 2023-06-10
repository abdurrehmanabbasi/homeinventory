import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/global.dart';
import 'package:inventory/models.dart';
import 'package:inventory/helpers/db_helper.dart';

class AddFilePage extends StatefulWidget {
  @override
  _AddFilePageState createState() => _AddFilePageState();
}

class _AddFilePageState extends State<AddFilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fileNameController = TextEditingController();
  File? _selectedImage;

  void _selectImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _selectImageFromCamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _uploadAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Please choose media to select'),
            content: Container(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                children: [
                  ElevatedButton(
                    //if user click this button, user can upload image from gallery
                    onPressed: () {
                      Navigator.pop(context);
                      _selectImageFromGallery();
                    },
                    child: Row(
                      children: [
                        Icon(Icons.image),
                        Text('From Gallery'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    //if user click this button. user can upload image from camera
                    onPressed: () {
                      Navigator.pop(context);
                      _selectImageFromCamera();
                    },
                    child: Row(
                      children: [
                        Icon(Icons.camera),
                        Text('From Camera'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _addFile() async {
    if (_formKey.currentState!.validate() && _selectedImage != null) {
      final fileBytes = await _selectedImage!.readAsBytes();
      final fileBase64 = base64Encode(fileBytes);

      final file = FileModel(
        id: generateUniqueId(),
        fileName: _fileNameController.text,
        fileImage: fileBase64,
      );

      final dbHelper = DbHelper();
      await dbHelper.insertFile(file);

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add File'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _fileNameController,
                  decoration: InputDecoration(labelText: 'File Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a file name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        height: 200,
                      )
                    : Container(),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _uploadAlert,
                  child: Text('Upload Image'),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _addFile,
                  child: Text('Add File'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
