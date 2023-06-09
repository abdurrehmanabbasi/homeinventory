import 'dart:io';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'package:path/path.dart';
import 'package:printing/printing.dart';
import 'package:sqflite/sqflite.dart';
import 'package:inventory/models.dart';
import 'package:path_provider/path_provider.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper.internal();
  factory DbHelper() => _instance;

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDatabase();
    return _database;
  }

  DbHelper.internal();

  Future<Database> initDatabase() async {
    final Directory databasesPath = await getApplicationDocumentsDirectory();

    final String path = join(databasesPath.path, 'newww.db');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE file (
          id INTEGER PRIMARY KEY,
          fileName TEXT,
          fileImage TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE room (
          id INTEGER PRIMARY KEY,
          roomName TEXT,
          roomImage TEXT,
          fileId INTEGER,
          FOREIGN KEY (fileId) REFERENCES file (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE item (
          id INTEGER PRIMARY KEY,
          itemName TEXT,
          itemDetails TEXT,
          itemImage TEXT,
          roomId INTEGER,
          loss INTEGER, 
          FOREIGN KEY (roomId) REFERENCES room (id)
        )
      ''');
    });
  }

  // File table methods
  Future<int> insertFile(FileModel file) async {
    final db = await database;
    return await db!.insert('file', file.toMap());
  }

  Future<List<FileModel>> getFiles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('file');
    return List.generate(maps.length, (i) {
      return FileModel.fromMap(maps[i]);
    });
  }

  Future<int> updateFile(FileModel file) async {
    final db = await database;
    return await db!.update(
      'file',
      file.toMap(),
      where: 'id = ?',
      whereArgs: [file.id],
    );
  }

  Future<int> deleteFile(int fileId) async {
    final db = await database;
    return await db!.delete(
      'file',
      where: 'id = ?',
      whereArgs: [fileId],
    );
  }

  // Room table methods
  Future<int> insertRoom(RoomModel room) async {
    final db = await database;
    return await db!.insert('room', room.toMap());
  }

  Future<List<RoomModel>> getRooms(int fileId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'room',
      where: 'fileId = ?',
      whereArgs: [fileId],
    );
    return List.generate(maps.length, (i) {
      return RoomModel.fromMap(maps[i]);
    });
  }

  Future<int> updateRoom(RoomModel room) async {
    final db = await database;
    return await db!.update(
      'room',
      room.toMap(),
      where: 'id = ?',
      whereArgs: [room.id],
    );
  }

  Future<int> deleteRoom(int roomId) async {
    final db = await database;
    return await db!.delete(
      'room',
      where: 'id = ?',
      whereArgs: [roomId],
    );
  }

  // Item table methods
  Future<int?> insertItem(ItemModel item, int roomId) async {
    final db = await database;
    final room = await getRoom(roomId);
    if (room != null) {
      item.roomId = room.id;
      return await db!.insert('item', item.toMap());
    }
    return null;
  }

  Future<List<ItemModel>> getItems(int roomId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'item',
      where: 'roomId = ?',
      whereArgs: [roomId],
    );
    return List.generate(maps.length, (i) {
      return ItemModel.fromMap(maps[i]);
    });
  }

  Future<int> updateItem(ItemModel item) async {
    final db = await database;
    return await db!.update(
      'item',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int itemId) async {
    final db = await database;
    return await db!.delete(
      'item',
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  Future<RoomModel?> getRoom(int roomId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'room',
      where: 'id = ?',
      whereArgs: [roomId],
    );
    if (maps.isNotEmpty) {
      return RoomModel.fromMap(maps.first);
    }
    return null;
  }

  Future<ItemModel?> getItem(int itemId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'item',
      where: 'id = ?',
      whereArgs: [itemId],
    );
    if (maps.isNotEmpty) {
      return ItemModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> generatePDF() async {
    final List<FileModel> files = await getFiles();
    final List<RoomModel> rooms = [];

    for (final file in files) {
      final List<RoomModel> fileRooms = await getRooms(file.id);
      rooms.addAll(fileRooms);
    }

    final pdf = pw.Document();

    final font = await PdfGoogleFonts.nunitoExtraLight();

    for (final file in files) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Text(file.fileName, style: pw.TextStyle(font: font)),
            );
          },
        ),
      );
    }

    for (final room in rooms) {
      final List<ItemModel> items = await getItems(room.id);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            final List<pw.Widget> itemWidgets = [];

            for (final item in items) {
              itemWidgets.add(
                pw.Text(item.itemName, style: pw.TextStyle(font: font)),
              );
              itemWidgets.add(
                pw.Text(item.itemDetails, style: pw.TextStyle(font: font)),
              );
              itemWidgets.add(
                pw.SizedBox(height: 10),
              );
            }

            return pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(room.roomName, style: pw.TextStyle(font: font)),
                  pw.Column(children: itemWidgets),
                ],
              ),
            );
          },
        ),
      );
    }

    final Directory appDocumentsDirectory =
        await getApplicationDocumentsDirectory();
    final String pdfPath = '${appDocumentsDirectory.path}/database_export.pdf';
    final File pdfFile = File(pdfPath);
    await pdfFile.writeAsBytes(await pdf.save());

    print(pdfPath);
  }
}
