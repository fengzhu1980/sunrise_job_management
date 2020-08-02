import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Note {
  String id;
  String relatedId;
  String note;
  DateTime createdAt;
  DateTime modifiedAt;
  String createdBy;
  String fristName;
  String lastName;
  bool isDeleted = false;

  Note({
    this.id,
    @required this.relatedId,
    @required this.note,
    this.createdAt,
    this.modifiedAt,
    this.createdBy,
    this.isDeleted,
    this.fristName,
    this.lastName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'relatedId': relatedId,
      'note': note,
      'createdAt': createdAt,
      'modifiedAt': modifiedAt,
      'isDeleted': isDeleted,
      'createdBy': createdBy,
      'fristName': fristName,
      'lastName': lastName,
    };
  }

  static Note fromSnapshot(DocumentSnapshot snapshot) {
    final returnNote = Note(
      id: snapshot.documentID,
      relatedId: snapshot['relatedId'],
      note: snapshot['note'],
      createdAt: DateTime.tryParse(snapshot['createdAt'].toString()),
      isDeleted: snapshot['isDeleted'],
      createdBy: snapshot['createdBy'],
      fristName: snapshot['fristName'],
      lastName: snapshot['lastName'],
    );

    if (snapshot['modifiedAt'] != null) {
      returnNote.modifiedAt =
          DateTime.tryParse(snapshot['modifiedAt'].toString());
    }

    return returnNote;
  }
}
