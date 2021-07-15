import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo/models/store.dart';

class StoreListViewModel extends ChangeNotifier {

  String message = "";

  Stream<QuerySnapshot> get storeAsStream {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance.collection("Users/${userId}/Stores").snapshots();
  }

  void refreshTheScreen() {
    notifyListeners();
  }

  Future<bool> deleteStore(Store store) async {
    bool isDeleted = false;
    try {
      await FirebaseFirestore.instance.collection('Stores').doc(store.id).delete();
      isDeleted = true;
      message = "Store has been deleted successfully.";
    } on Exception catch (_) {
      message = "Something error occurred.";
    } catch (_) {
      message = "Something error occurred.";
    }
    notifyListeners();
    return isDeleted;
  }

  List<Store> getStores(QuerySnapshot snap) {
    List<Store> stores = snap.docs.map((doc) {
      return Store.fromSnapshot(doc);
    }).toList();
    return stores;
  }
}
