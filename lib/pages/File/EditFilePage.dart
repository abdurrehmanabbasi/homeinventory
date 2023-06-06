import 'package:flutter/material.dart';
import 'package:inventory/models/File.dart';

class EditFilePage extends StatefulWidget {
  final FileModel file;

  EditFilePage(this.file);

  @override
  _EditFilePageState createState() => _EditFilePageState();
}

class _EditFilePageState extends State<EditFilePage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.file.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _updateFile() {
    if (_nameController.text.isNotEmpty) {
      final updatedFile = FileModel(
        id: widget.file.id,
        name: _nameController.text,
        rooms: widget.file.rooms,
      );

      Navigator.pop(context, updatedFile);
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
        title: Text('Edit File'),
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
              onPressed: _updateFile,
              child: Text('Update File'),
            ),
          ],
        ),
      ),
    );
  }
}
