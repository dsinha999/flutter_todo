import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  String name;
  String quantity;
  String price;
  String id = "";

  Item({required this.name, required this.quantity, required this.price});

  Map<String, dynamic> toMap() {
    return {"name": name, "quantity": quantity, "price": price};
  }

  factory Item.fromSnapshot(DocumentSnapshot snapshot) {
    final map = snapshot.data() as Map;
    Item itemObj =
        Item(name: map["name"], quantity: map["quantity"], price: map["price"]);
    itemObj.id = snapshot.id;
    return itemObj;
  }
}
