import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Store {

  final String name;
  final String address;
  String id = "";
  String? imageUrl;


Future<int> get itemsCount async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  final snapshot = await FirebaseFirestore.instance.collection("Users/${userId}/Stores/$id/items").get();
  return snapshot.docs.length;
}

  Store(this.name, this.address, {this.imageUrl});

  factory Store.fromSnapshot(DocumentSnapshot snapshot) {
    final map = snapshot.data() as Map;
    Store storeObj = Store(map["name"], map["address"], imageUrl: map["imageUrl"]);
    storeObj.id = snapshot.id;
    return storeObj;
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name, 
      "address": address,
      "imageUrl": imageUrl
      };
  }
}
