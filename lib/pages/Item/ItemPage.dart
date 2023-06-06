import 'package:flutter/material.dart';
import 'package:inventory/models/Item.dart';
import 'package:inventory/models/Room.dart';

class ItemPage extends StatelessWidget {
  final RoomModel room;

  ItemPage({required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items'),
      ),
      body: ListView.builder(
        itemCount: room.items.length,
        itemBuilder: (context, index) {
          final item = room.items[index];
          return ListTile(
            leading: Image.network(item.image),
            title: Text(item.name),
            subtitle: Text(item.details),
          );
        },
      ),
    );
  }
}
