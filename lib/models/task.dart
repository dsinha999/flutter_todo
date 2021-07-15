import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String name;
  final String id;

  Task(this.name, this.id);

  factory Task.fromSnapshot(DocumentSnapshot snapshot) {
    final map = snapshot.data() as Map;
    return Task(map["Task Name"], snapshot.id);
  }

}
