import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inventory/models/File.dart';

class AddFilePage extends StatefulWidget {
  @override
  _AddFilePageState createState() => _AddFilePageState();
}

class _AddFilePageState extends State<AddFilePage> {
  TextEditingController _nameController = TextEditingController();

  int _generateUniqueId() {
    final random = Random();
    return random.nextInt(9999999) + DateTime.now().millisecondsSinceEpoch;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitFile() {
    if (_nameController.text.isNotEmpty) {
      final newFile =
          FileModel(id: _generateUniqueId(), name: _nameController.text);

      Navigator.pop(context, newFile);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please enter a valid file name.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add File'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'File Name',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter file name',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitFile,
              child: Text('Add File'),
            ),
          ],
        ),
      ),
    );
  }
}
