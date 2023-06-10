import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/models.dart';
import 'package:inventory/helpers/db_helper.dart';

class EditRoomPage extends StatefulWidget {
  final RoomModel room;

  EditRoomPage({required this.room});

  @override
  _EditRoomPageState createState() => _EditRoomPageState();
}

class _EditRoomPageState extends State<EditRoomPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _roomNameController;

  File? _selectedImage;

  _EditRoomPageState() : _roomNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _roomNameController.text = widget.room.roomName;
  }

  @override
  void dispose() {
    _roomNameController.dispose();
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

  void _updateRoom() async {
    if (_formKey.currentState!.validate()) {
      final roomName = _roomNameController.text;

      String roomImage = widget.room.roomImage;
      if (_selectedImage != null) {
        final imageBytes = await _selectedImage!.readAsBytes();
        roomImage = base64Encode(imageBytes);
      }

      final updatedRoom = RoomModel(
        id: widget.room.id,
        roomName: roomName,
        roomImage: roomImage,
        fileId: widget.room.fileId,
      );

      final dbHelper = DbHelper();
      await dbHelper.updateRoom(updatedRoom);

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Room'),
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
                  onPressed: _uploadAlert,
                  child: Text('Select Image'),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _updateRoom,
                  child: Text('Update Room'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
