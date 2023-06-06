import 'package:flutter/material.dart';
import 'package:inventory/helpers/db_helper.dart';
import 'package:inventory/models/File.dart';
import 'AddFilePage.dart';
import 'EditFilePage.dart';
import 'package:inventory/pages/Room/RoomPage.dart';

class FilePage extends StatefulWidget {
  @override
  _FilePageState createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  List<FileModel> _files = [];
  DbHelper _dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  Future<void> _fetchFiles() async {
    final files = await _dbHelper.getAllFiles();
    setState(() {
      _files = files;
    });
  }

  void _editFile(FileModel file) async {
    final updatedFile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFilePage(file),
      ),
    );

    if (updatedFile != null && updatedFile is FileModel) {
      // Update the file in the database
      await _dbHelper.updateFile(updatedFile);

      // Fetch the updated list of files
      _fetchFiles();
    }
  }

  Future<void> _deleteFile(int fileId) async {
    await _dbHelper.deleteFile(fileId);
    _fetchFiles();
  }

  Future<void> _addFile() async {
    // Navigate to a new screen to collect file details
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFilePage()),
    );

    if (result != null && result is FileModel) {
      // Insert the new file into the database
      await _dbHelper.insertFile(result);

      // Fetch the updated list of files
      _fetchFiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Files'),
      ),
      body: ListView.builder(
        itemCount: _files.length,
        itemBuilder: (context, index) {
          final file = _files[index];
          return ListTile(
            title: Text(file.name),
            onTap: () {
              // Handle tap to view all rooms
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoomPage(file),
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _editFile(file);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete File'),
                        content:
                            Text('Are you sure you want to delete this file?'),
                        actions: [
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: Text('Delete'),
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteFile(file.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFile,
        child: Icon(Icons.add),
      ),
    );
  }
}
