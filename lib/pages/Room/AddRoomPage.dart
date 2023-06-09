import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/global.dart';
import 'package:inventory/models.dart';
import 'package:inventory/helpers/db_helper.dart';

class AddRoomPage extends StatefulWidget {
  final FileModel file;

  AddRoomPage({required this.file});

  @override
  _AddRoomPageState createState() => _AddRoomPageState();
}

class _AddRoomPageState extends State<AddRoomPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _roomNameController = TextEditingController();
  File? _selectedImage;

  void _selectImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _addRoom() async {
    if (_formKey.currentState!.validate() && _selectedImage != null) {
      final imageBytes = await _selectedImage!.readAsBytes();
      final roomImage = base64Encode(imageBytes);

      final room = RoomModel(
        id: generateUniqueId(),
        roomName: _roomNameController.text,
        roomImage: roomImage,
        fileId: widget.file.id,
      );

      final dbHelper = DbHelper();
      await dbHelper.insertRoom(room);

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Room'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _roomNameController,
                  decoration: InputDecoration(labelText: 'Room Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a room name';
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
                  onPressed: _selectImage,
                  child: Text('Select Image'),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _addRoom,
                  child: Text('Add Room'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
