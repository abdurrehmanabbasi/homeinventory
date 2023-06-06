import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inventory/models/File.dart';
import 'package:inventory/models/Room.dart';

import 'package:inventory/helpers/db_helper.dart';
import 'package:inventory/pages/Item/ItemPage.dart';

class RoomPage extends StatefulWidget {
  final FileModel file;

  RoomPage(this.file);

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  late DbHelper _dbHelper;
  List<RoomModel> _rooms = [];

  int _generateUniqueId() {
    final random = Random();
    return random.nextInt(9999999) + DateTime.now().millisecondsSinceEpoch;
  }

  @override
  void initState() {
    super.initState();
    _dbHelper = DbHelper();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    final rooms = await _dbHelper.getRoomsByFileId(widget.file.id);
    setState(() {
      _rooms = rooms;
    });
  }

  Future<void> _addNewRoom() async {
    final newRoom = RoomModel(
      id: _generateUniqueId(),
      name: 'New Room',
      items: [],
    );

    await _dbHelper.insertRoom(newRoom);
    _fetchRooms();
  }

  Future<void> _editRoom(RoomModel room) async {
    // final updatedRoom = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => EditRoomPage(room),
    //   ),
    // );

    // if (updatedRoom != null && updatedRoom is RoomModel) {
    //   await _dbHelper.updateRoom(updatedRoom);
    //   _fetchRooms();
    // }
  }

  Future<void> _deleteRoom(RoomModel room) async {
    await _dbHelper.deleteRoom(room.id);
    _fetchRooms();
  }

  Future<void> _viewItems(RoomModel room) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemPage(room: room),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rooms'),
      ),
      body: ListView.builder(
        itemCount: _rooms.length,
        itemBuilder: (context, index) {
          final room = _rooms[index];
          return ListTile(
            title: Text(room.name),
            onTap: () {
              _viewItems(room);
            },
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteRoom(room);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewRoom,
        child: Icon(Icons.add),
      ),
    );
  }
}
