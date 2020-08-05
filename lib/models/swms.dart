import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Swms {
  String id;
  String title;
  DateTime createdAt;
  bool isActive;

  Swms({
    this.id,
    @required this.title,
    this.createdAt,
    @required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }

  static Swms fromSnapshot(DocumentSnapshot snapshot) {
    return Swms(
      id: snapshot.documentID,
      title: snapshot['title'],
      createdAt: DateTime.tryParse(snapshot['createdAt'].toDate().toString()),
      isActive: snapshot['isActive'],
    );
  }
}
