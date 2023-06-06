import 'Room.dart';

class FileModel {
  int id;
  String name;
  List<RoomModel> rooms;

  FileModel({required this.id, required this.name, List<RoomModel>? rooms})
      : rooms = rooms ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory FileModel.fromMap(Map<String, dynamic> map) {
    return FileModel(
      id: map['id'],
      name: map['name'],
    );
  }
}
