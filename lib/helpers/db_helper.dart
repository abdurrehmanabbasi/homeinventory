import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:inventory/models/File.dart';
import 'package:inventory/models/Room.dart';
import 'package:inventory/models/Item.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper.internal();
  factory DbHelper() => _instance;

  static Database? _database;

  DbHelper.internal();

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'my_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE files(
            id INTEGER PRIMARY KEY,
            name TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE rooms(
            id INTEGER PRIMARY KEY,
            name TEXT,
            fileId INTEGER,
            FOREIGN KEY (fileId) REFERENCES files (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE items(
            id INTEGER PRIMARY KEY,
            image TEXT,
            name TEXT,
            details TEXT,
            roomId INTEGER,
            FOREIGN KEY (roomId) REFERENCES rooms (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  Future<void> insertFile(FileModel file) async {
    final db = await database;
    await db!.insert('files', file.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertRoom(RoomModel room) async {
    final db = await database;
    await db!.insert('rooms', room.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertItem(ItemModel item) async {
    final db = await database;
    await db!.insert('items', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FileModel>> getAllFiles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('files');
    return List.generate(maps.length, (i) {
      return FileModel.fromMap(maps[i]);
    });
  }

  Future<List<RoomModel>> getRoomsByFileId(int fileId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db!.query('rooms', where: 'fileId = ?', whereArgs: [fileId]);
    return List.generate(maps.length, (i) {
      return RoomModel.fromMap(maps[i]);
    });
  }

  Future<List<ItemModel>> getItemsByRoomId(int roomId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db!.query('items', where: 'roomId = ?', whereArgs: [roomId]);
    return List.generate(maps.length, (i) {
      return ItemModel.fromMap(maps[i]);
    });
  }

  Future<void> updateFile(FileModel file) async {
    final db = await database;
    await db!.update(
      'files',
      file.toMap(),
      where: 'id = ?',
      whereArgs: [file.id],
    );
  }

  Future<void> updateRoom(RoomModel room) async {
    final db = await database;
    await db!.update(
      'rooms',
      room.toMap(),
      where: 'id = ?',
      whereArgs: [room.id],
    );
  }

  Future<void> updateItem(ItemModel item) async {
    final db = await database;
    await db!.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteFile(int fileId) async {
    final db = await database;
    await db!.delete('files', where: 'id = ?', whereArgs: [fileId]);
  }

  Future<void> deleteRoom(int roomId) async {
    final db = await database;
    await db!.delete('rooms', where: 'id = ?', whereArgs: [roomId]);
  }

  Future<void> deleteItem(int itemId) async {
    final db = await database;
    await db!.delete('items', where: 'id = ?', whereArgs: [itemId]);
  }
}
