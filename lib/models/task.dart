import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Task {
  String id;
  double price;
  String task;
  double hours;
  DateTime createdAt;
  bool isActive;

  Task({
    @required this.id,
    @required this.price,
    @required this.task,
    @required this.hours,
    this.createdAt,
    @required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'price': price,
      'task': task,
      'hours': hours,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }

  static Task fromSnapshot(DocumentSnapshot snapshot) {
    final returnTask = Task(
      id: snapshot.documentID,
      // price: snapshot['price'],
      task: snapshot['task'],
      createdAt: DateTime.tryParse(snapshot['createdAt'].toDate().toString()),
      isActive: snapshot['isActive'],
    );

    if (snapshot['price'] != null) {
      returnTask.price = snapshot['price'].toDouble();
    }

    if (snapshot['hours'] != null) {
      returnTask.hours = snapshot['hours'].toDouble();
    }
    return returnTask;
  }
}
