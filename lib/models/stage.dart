import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Stage {
  String id;
  String stage;
  DateTime createdAt;
  bool isActive;

  Stage({
    @required this.id,
    @required this.stage,
    this.createdAt,
    @required isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stage': stage,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }

  static Stage fromSnapshot(DocumentSnapshot snapshot) {
    final returnStage = Stage(
      id: snapshot.documentID,
      stage: snapshot['stage'],
      createdAt: DateTime.tryParse(snapshot['createdAt'].toDate().toString()),
      isActive: snapshot['isActive'],
    );
    return returnStage;
  }
}
