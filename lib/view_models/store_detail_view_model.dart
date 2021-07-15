import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo/models/item.dart';
import 'package:flutter_todo/models/store.dart';

class StoreDetailViewModel extends ChangeNotifier {

  Store store;

  Item item = Item(name: "", quantity: "", price: "");

  String message = "";

  Stream<QuerySnapshot> get itemAsStream {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance.collection("Users/${userId}/Stores/${store.id}/items").snapshots();
  }

  StoreDetailViewModel(this.store);

  void resetItem() {
    item = Item(name: "", quantity: "", price: "");
    notifyListeners();
  }

  Future<bool> saveItem() async {
    bool isSaved = false;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    try {
      await FirebaseFirestore.instance
          .collection("Users/${userId}/Stores/${store.id}/items")
          .add(item.toMap());
      message = "Store has been successfully saved";
      isSaved = true;
    } on Exception catch (error) {
      message = "Something went wrong!";
    } catch (error) {
      message = "Something went wrong!";
    }

    if (isSaved) {
      resetItem();
    }

    notifyListeners();

    return isSaved;
  }


List<Item> getItems(QuerySnapshot snap) {
    List<Item> items = snap.docs.map((doc) {
      return Item.fromSnapshot(doc);
    }).toList();
    return items;
  }


}
