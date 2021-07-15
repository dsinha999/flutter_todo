import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  String email = "";
  String password = "";

  Future<String?> loginUser() async {
    String? message;
    try {
      final credentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      message = null;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      message = e.message;
    } catch (e) {
      print(e.toString());
      message = e.toString();
    }
    return message;
  }
}
