import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/global.dart';
import 'package:inventory/models.dart';
import 'package:inventory/helpers/db_helper.dart';

class EditItemPage extends StatefulWidget {
  final ItemModel item;

  EditItemPage({required this.item});

  @override
  _EditItemPageState createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _itemNameController;
  late TextEditingController _itemDescriptionController;
  late bool isLoss;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _itemNameController = TextEditingController(text: widget.item.itemName);
    _itemDescriptionController =
        TextEditingController(text: widget.item.itemDetails);
    isLoss = widget.item.loss;
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    super.dispose();
  }

  void _selectImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _updateItem() async {
    if (_formKey.currentState!.validate()) {
      final String itemName = _itemNameController.text;
      final String itemDescription = _itemDescriptionController.text;
      String itemImage =
          widget.item.itemImage!; // Retain the existing item image
      if (_selectedImage != null) {
        final imageBytes = await _selectedImage!.readAsBytes();
        itemImage = base64Encode(imageBytes);
      }
      final dbHelper = DbHelper();
      final ItemModel updatedItem = ItemModel(
        id: widget.item.id,
        itemName: itemName,
        itemDetails: itemDescription,
        itemImage: itemImage,
        loss: isLoss,
        roomId: widget.item.roomId,
      );

      await dbHelper.updateItem(updatedItem);

      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Item'),
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
                Row(
                  children: [
                    Checkbox(
                        value: isLoss,
                        onChanged: (bool? value) {
                          setState(() {
                            isLoss = value!;
                          });
                        }),
                    Text("Loss ")
                  ],
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
                  onPressed: _updateItem,
                  child: Text('Update Item'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
