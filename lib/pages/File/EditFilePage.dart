import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/models.dart';
import 'package:inventory/helpers/db_helper.dart';

class EditFilePage extends StatefulWidget {
  final FileModel file;

  EditFilePage({required this.file});

  @override
  _EditFilePageState createState() => _EditFilePageState();
}

class _EditFilePageState extends State<EditFilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _fileNameController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController(text: widget.file.fileName);
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

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
                    onPressed: _selectImageFromGallery,
                    child: Row(
                      children: [
                        Icon(Icons.image),
                        Text('From Gallery'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    //if user click this button. user can upload image from camera
                    onPressed: _selectImageFromCamera,
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

  void _updateFile() async {
    if (_formKey.currentState!.validate()) {
      final String fileName = _fileNameController.text;
      final String? fileImage = _selectedImage != null
          ? base64Encode(await _selectedImage!.readAsBytes())
          : widget.file.fileImage;

      final dbHelper = DbHelper();
      final FileModel updatedFile = FileModel(
        id: widget.file.id,
        fileName: fileName,
        fileImage: fileImage!,
      );

      await dbHelper.updateFile(updatedFile);

      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit File'),
      ),
      body: Padding(
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
                child: Text('Select Image'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _updateFile,
                child: Text('Update File'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
