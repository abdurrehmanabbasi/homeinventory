import 'package:flutter/material.dart';
import 'package:inventory/models.dart';
import 'package:inventory/helpers/db_helper.dart';
import 'package:inventory/pages/Item/ItemsPage.dart';
import 'dart:convert';

import '../../helpers/generate_report.dart';
import '../../widgets/AnimatedListTile.dart';
import 'AddRoomPage.dart';
import 'EditRoomPage.dart';

class RoomPage extends StatefulWidget {
  final FileModel file;

  RoomPage({required this.file});

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  List<RoomModel> _rooms = [];

  @override
  void initState() {
    super.initState();
    _getRooms();
  }

  Future<void> _getRooms() async {
    final dbHelper = DbHelper();
    final rooms = await dbHelper.getRooms(widget.file.id);
    setState(() {
      _rooms = rooms;
    });
  }

  void _addRoom() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddRoomPage(
                file: widget.file,
              )),
    ).then((_) {
      _getRooms();
    });
  }

  void _editRoom(RoomModel room) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditRoomPage(room: room)),
    ).then((shouldRefresh) {
      if (shouldRefresh == true) {
        _getRooms();
      }
    });
  }

  void _deleteRoom(RoomModel room) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Room'),
          content: Text('Are you sure you want to delete this Room?'),
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
                _performDelete(room);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _performDelete(RoomModel room) async {
    final dbHelper = DbHelper();
    await dbHelper.deleteRoom(room.id);
    _getRooms();
  }

  void _viewItems(RoomModel room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemsPage(room: room),
      ),
    );
  }

  Widget _buildRoomItem(BuildContext context, int index) {
    final room = _rooms[index];
    final imageBytes = base64Decode(room.roomImage);

    return AnimatedListTile(
        imageBytes: imageBytes,
        title: room.roomName,
        onDeletePressed: () => _deleteRoom(room),
        onEditPressed: () => _editRoom(room),
        onTapPressed: () => _viewItems(room));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.file.fileName} Rooms'), actions: [
        ElevatedButton(
          onPressed: () async {
            final report = Report();
            await report.byFile(widget.file);
          },
          child: Icon(Icons.picture_as_pdf_sharp),
        )
      ]),
      body: _rooms.isEmpty
          ? const Center(
              child: Text('No Room Available.Tap + to Add Room.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : ListView.builder(
              itemCount: _rooms.length,
              itemBuilder: _buildRoomItem,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRoom,
        child: Icon(Icons.add),
      ),
    );
  }
}
