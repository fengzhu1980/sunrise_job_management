import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Task {
  String id;
  double price;
  String task;
  DateTime createdAt;
  bool isActive;

  Task({
    @required this.id,
    @required this.price,
    @required this.task,
    this.createdAt,
    @required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'price': price,
      'task': task,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }

  static Task fromSnapshot(DocumentSnapshot snapshot) {
    final returnTask = Task(
      id: snapshot.documentID,
      // price: snapshot['price'],
      task: snapshot['task'],
      createdAt: DateTime.tryParse(snapshot['createdAt'].toString()),
      isActive: snapshot['isActive'],
    );

    if (snapshot['price'] != null) {
      returnTask.price = snapshot['price'].toDouble();
    }
    return returnTask;
  }
}
