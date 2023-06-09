class FileModel {
  int id;
  String fileName;
  String fileImage;

  FileModel({
    required this.id,
    required this.fileName,
    required this.fileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'fileImage': fileImage,
    };
  }

  static FileModel fromMap(Map<String, dynamic> map) {
    return FileModel(
      id: map['id'],
      fileName: map['fileName'],
      fileImage: map['fileImage'],
    );
  }
}

class RoomModel {
  int id;
  String roomName;
  String roomImage;
  int fileId;
  List<ItemModel> items; // Add items property

  RoomModel({
    required this.id,
    required this.roomName,
    required this.roomImage,
    required this.fileId,
    this.items = const [], // Initialize items as an empty list
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomName': roomName,
      'roomImage': roomImage,
      'fileId': fileId,
    };
  }

  static RoomModel fromMap(Map<String, dynamic> map) {
    return RoomModel(
      id: map['id'],
      roomName: map['roomName'],
      roomImage: map['roomImage'],
      fileId: map['fileId'],
    );
  }
}

class ItemModel {
  int id;
  String itemName;
  String itemDetails;
  String itemImage;
  int roomId;
  bool loss; // Added loss property

  ItemModel(
      {required this.id,
      required this.itemName,
      required this.itemDetails,
      required this.itemImage,
      required this.roomId,
      this.loss = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': itemName,
      'itemDetails': itemDetails,
      'itemImage': itemImage,
      'roomId': roomId,
      'loss': loss,
    };
  }

  static ItemModel fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'],
      itemName: map['itemName'],
      itemDetails: map['itemDetails'],
      itemImage: map['itemImage'],
      roomId: map['roomId'],
      loss: map['loss'] == 1,
    );
  }
}
