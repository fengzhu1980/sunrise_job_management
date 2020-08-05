import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Hazard {
  String id;
  String title;
  String description;
  List swms;
  DateTime createdAt;
  DateTime modifiedAt;
  bool isActive;

  Hazard({
    this.id,
    @required this.title,
    this.description,
    this.swms,
    this.createdAt,
    this.modifiedAt,
    @required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'swms': swms,
      'createdAt': createdAt,
      'modifiedAt': modifiedAt,
      'isActive': isActive,
    };
  }

  static Hazard fromSnapshot(DocumentSnapshot snapshot) {
    final returnHazard = Hazard(
      id: snapshot.documentID,
      title: snapshot['title'],
      description: snapshot['description'],
      swms: List.from(snapshot['swms']),
      createdAt: DateTime.tryParse(snapshot['createdAt'].toDate().toString()),
      isActive: snapshot['isActive'],
    );

    if (snapshot['modifiedAt'] != null) {
      returnHazard.modifiedAt =
          DateTime.tryParse(snapshot['modifiedAt'].toString());
    }

    return returnHazard;
  }
}
