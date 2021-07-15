import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_todo/models/task.dart';

class TasksPage extends StatelessWidget {
  final TextEditingController _addTaskTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _addTask(BuildContext context) {
    if (_addTaskTextController.text.length == 0) {
      final snackBar = SnackBar(content: Text('Please enter the task name.!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    FirebaseFirestore.instance
        .collection('ToDos')
        .add({"Task Name": _addTaskTextController.text});

    _addTaskTextController.text = "";
  }

  void _removeTask(Task task) {
    FirebaseFirestore.instance.collection('ToDos').doc(task.id).delete();
  }

  Widget _buildTasksList(QuerySnapshot snapshot) {
    return ListView.builder(
      itemCount: snapshot.docs.length,
      itemBuilder: (context, index) {
        final task = Task.fromSnapshot(snapshot.docs[index]);

        return Dismissible(
          key: Key(task.id),
          background: Container(
            color: Colors.red,
            child: Row(children: [
              Expanded(child: SizedBox()),
              Text(
                'Delete',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(
                width: 16,
              )
            ]),
          ),
          onDismissed: (direction) {
            _removeTask(task);
          },
          direction: DismissDirection.endToStart,
          child: Column(
            children: [
              ListTile(
                title: Text(task.name),
              ),
              Divider(),
            ],
          ),
        );
      },
      controller: _scrollController,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 16,
              ),
              Expanded(
                child: TextField(
                  controller: _addTaskTextController,
                  decoration: InputDecoration(
                    hintText: 'Enter Task Name...',
                  ),
                ),
              ),
              SizedBox(
                width: 12,
              ),
              ElevatedButton(
                  onPressed: () {
                    _addTask(context);
                  },
                  child: Text('ADD')),
              SizedBox(
                width: 16,
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('ToDos').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox(
                  width: 0,
                  height: 0,
                );
              }

              return Expanded(
                child: _buildTasksList(snapshot.data!),
              );
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextButton(
            onPressed: () {
              print('Title Tapped .....');
            },
            child: Text(
              'Todo',
              style: TextStyle(color: Colors.white, fontSize: 23),
            )),
      ),
      body: _buildBody(context),
    );
  }
}
