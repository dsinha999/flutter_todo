import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

enum Gender { 
  Male, 
  Female 
}

class RegisterViewModel extends ChangeNotifier {
  static final dropDownPlaceholder = "Select Qualification";

  String name = "";
  String email = "";
  String password = "";
  DateTime? dob;
  Gender gender = Gender.Male;
  PickedFile? imageFile;

  String qualification = RegisterViewModel.dropDownPlaceholder;

  void setImageFile(PickedFile? file) {
    this.imageFile = file;
    notifyListeners();
  }

  Future<bool> createUser() async {
    bool isCreated = false;
    try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        isCreated = true;
    } on FirebaseAuthException catch(_) {}
    return isCreated;
  }

  Future<bool> loginUser() async {
    bool isLogin = false;
    try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        isLogin = true;
    } on FirebaseAuthException catch(_) {}
    return isLogin;
  }


  Future<bool> registerUser({String? imageURL}) async {

    bool isVerified = false;
    final userID = await FirebaseAuth.instance.currentUser?.uid;
    if (userID == null) {
        return isVerified;
    }

    try {
      await FirebaseFirestore.instance.collection("Users").doc(userID).set(
        {
          "name" : name,
          "email" : email,
          "password" : password,
          "profilePicture": imageURL,
          "dob": dob,
          "qualification" : qualification,
          "gender" : describeEnum(gender)
        }
      );
    } catch (e) {

    }

    return isVerified;
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

  static List<String> getQualifications() {
    return [
      RegisterViewModel.dropDownPlaceholder,
      "Matriculation",
      "10+2",
      "Graduation",
      "Post Graduation",
      "Phd",
    ];
  }
}
