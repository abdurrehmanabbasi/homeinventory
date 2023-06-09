import 'package:flutter/material.dart';
import 'package:inventory/models.dart';
import 'package:inventory/helpers/db_helper.dart';
import 'dart:convert';

import '../../widgets/AnimatedListTile.dart';
import 'AddItemPage.dart';
import 'EditItemPage.dart';
import 'ItemPage.dart';

class ItemsPage extends StatefulWidget {
  final RoomModel room;

  ItemsPage({required this.room});

  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  List<ItemModel> _items = [];

  @override
  void initState() {
    super.initState();
    _getItems();
  }

  Future<void> _getItems() async {
    final dbHelper = DbHelper();
    final items = await dbHelper.getItems(widget.room.id);
    setState(() {
      _items = items;
    });
  }

  void _addItem() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddItemPage(
                room: widget.room,
              )),
    ).then((_) {
      _getItems();
    });
  }

  void _editItem(ItemModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditItemPage(item: item)),
    ).then((shouldRefresh) {
      if (shouldRefresh == true) {
        _getItems();
      }
    });
  }

  void _deleteItem(ItemModel item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Item'),
          content: Text('Are you sure you want to delete this Item?'),
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
                _performDelete(item);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _performDelete(ItemModel item) async {
    final dbHelper = DbHelper();
    await dbHelper.deleteItem(item.id);
    _getItems();
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = _items[index];

    return AnimatedListTile(
      imageBytes: base64Decode(item.itemImage),
      title: item.itemName,
      onDeletePressed: () => _deleteItem(item),
      onEditPressed: () => _editItem(item),
      onTapPressed: () => _viewItem(item),
      loss: item.loss,
    );
  }

  void _viewItem(ItemModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemPage(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items Page'),
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text('No Items Available. Tap + to Add Item.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: _buildItem,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: Icon(Icons.add),
      ),
    );
  }
}
