import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Task {
  final String id;
  final String price;
  final String task;

  Task({@required this.id, @required this.price, @required this.task});

  Map<String, dynamic> toMap() {
    return {'id': id, 'price': price, 'task': task};
  }

  static Task fromSnapshot(DocumentSnapshot snapshot) {
    final returnTask = Task(
        id: snapshot.documentID,
        price: snapshot['price'],
        task: snapshot['task']);
    return returnTask;
  }
}
