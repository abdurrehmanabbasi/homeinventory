import 'Item.dart';

class RoomModel {
  int id;
  String name;
  List<ItemModel> items;

  RoomModel({required this.id, required this.name, List<ItemModel>? items})
      : items = items ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      id: map['id'],
      name: map['name'],
      items: [],
    );
  }
}
