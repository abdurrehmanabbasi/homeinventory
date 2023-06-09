import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inventory/models.dart';

class ItemPage extends StatelessWidget {
  final ItemModel item;

  ItemPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.memory(base64Decode(item.itemImage), fit: BoxFit.cover),
            SizedBox(
              height: 8.0,
            ),
            Text(
              'Name: ${item.itemName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text('Description: ${item.itemDetails}'),
            SizedBox(height: 8.0),
            Text('Loss is ${item.loss}')
            // Add more details of the item as needed
          ],
        ),
      ),
    );
  }
}
