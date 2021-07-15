import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo/models/store.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddStoreViewModel extends ChangeNotifier {
  String name = "";
  String address = "";
  PickedFile? imageFile;
  String? url;

  String message = "";

  void setImageFile(PickedFile? file) {
    this.imageFile = file;
    notifyListeners();
  }

  Future<bool> saveStore() async {
    bool isSaved = false;
    final userID = FirebaseAuth.instance.currentUser?.uid;
    try {
      await FirebaseFirestore.instance
          .collection("Users/${userID!}/Stores")
          .add(Store(name, address, imageUrl: url).toMap());
      message = "Store has been successfully saved";
      isSaved = true;
    } on Exception catch (_) {
      message = "Something went wrong!";
    } catch (_) {
      message = "Something went wrong!";
    }

    notifyListeners();
    return isSaved;
  }

  Future<Map<String, dynamic>> uploadImage() async {
    bool isUploaded = false;
    String? url;

    final fileName = Uuid().v1();

    final task = FirebaseStorage.instance
        .ref()
        .child(fileName)
        .putFile(File(imageFile!.path));

    task.snapshotEvents.listen((TaskSnapshot snapshot) {
      print('Task state: ${snapshot.state}');
      print(
          'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
    }, onError: (e) {
      print(task.snapshot);
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
      }
      return {"isUploaded": isUploaded, "url": url};
    });

    try {
      await task;
      isUploaded = true;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
      }
      return {"isUploaded": isUploaded, "url": url};
    }

    url = await task.snapshot.ref.getDownloadURL();

    return {"isUploaded": isUploaded, "url": url};
  }

}
