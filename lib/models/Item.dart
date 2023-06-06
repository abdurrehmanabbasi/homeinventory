class ItemModel {
  int id;
  String image;
  String name;
  String details;

  ItemModel(
      {required this.id,
      required this.image,
      required this.name,
      required this.details});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'details': details,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'],
      image: map['image'],
      name: map['name'],
      details: map['details'],
    );
  }
}
