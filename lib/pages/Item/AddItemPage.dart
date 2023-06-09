import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/global.dart';
import 'package:inventory/models.dart';
import 'package:inventory/helpers/db_helper.dart';

class AddItemPage extends StatefulWidget {
  final RoomModel room;

  AddItemPage({required this.room});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemDescriptionController =
      TextEditingController();
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

  void _addItem() async {
    if (_formKey.currentState!.validate() && _selectedImage != null) {
      final itemBytes = await _selectedImage!.readAsBytes();
      final itemBase64 = base64Encode(itemBytes);

      final item = ItemModel(
        id: generateUniqueId(),
        itemName: _itemNameController.text,
        itemDetails: _itemDescriptionController.text,
        itemImage: itemBase64,
        roomId: widget.room.id,
      );

      final dbHelper = DbHelper();
      await dbHelper.insertItem(item, widget.room.id);

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _itemNameController,
                  decoration: InputDecoration(labelText: 'Item Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an item name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  minLines: 6,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  controller: _itemDescriptionController,
                  decoration: InputDecoration(labelText: 'Item Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an item description';
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
                  onPressed: _addItem,
                  child: Text('Add Item'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
