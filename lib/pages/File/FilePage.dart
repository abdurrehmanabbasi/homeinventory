import 'package:flutter/material.dart';
import 'package:inventory/models.dart';
import 'package:inventory/helpers/db_helper.dart';
import 'dart:convert';

import '../../widgets/AnimatedListTile.dart';
import '../Room/RoomPage.dart';
import 'AddFilePage.dart';
import 'EditFilePage.dart';

class FilePage extends StatefulWidget {
  @override
  _FilePageState createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  List<FileModel> _files = [];

  late List<RoomModel> _rooms;

  @override
  void initState() {
    super.initState();
    _rooms = [];
    _getFiles();
  }

  Future<void> _getFiles() async {
    final dbHelper = DbHelper(); // Create an instance of DbHelper
    final files = await dbHelper.getFiles(); // Call getFiles on the instance
    setState(() {
      _files = files;
    });
  }

  Widget _buildFileItem(BuildContext context, int index) {
    final file = _files[index];
    final imageBytes = base64Decode(file.fileImage!); // Decode the base64 image
    return AnimatedListTile(
      imageBytes: imageBytes,
      title: file.fileName,
      onTapPressed: () => _viewRoomPage(file),
      onDeletePressed: () => _deleteFile(file),
      onEditPressed: () => _editFile(file),
    );
  }

  void _viewRoomPage(FileModel file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomPage(file: file),
      ),
    );
  }

  void _editFile(FileModel file) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditFilePage(file: file)),
    ).then((shouldRefresh) {
      if (shouldRefresh == true) {
        _getFiles();
      }
    });
  }

  void _deleteFile(FileModel file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete File'),
          content: Text('Are you sure you want to delete this file?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _performDelete(file);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _performDelete(FileModel file) async {
    final dbHelper = DbHelper();
    await dbHelper.deleteFile(file.id);
    _getFiles();
  }

  void _addFile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFilePage()),
    ).then((_) {
      _getFiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Files'), actions: [
        ElevatedButton(
          onPressed: () async {
            final dbHelper = DbHelper();
            await dbHelper.generatePDF();
          },
          child:
              Row(children: [Text('Export'), Icon(Icons.picture_as_pdf_sharp)]),
        )
      ]),
      body: _files.isEmpty
          ? const Center(
              child: Text('No File Available.Tap + to Add File.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : ListView.builder(
              itemCount: _files.length,
              itemBuilder: _buildFileItem,
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addFile,
      ),
    );
  }

  void _exportAsPDF() async {}
}
