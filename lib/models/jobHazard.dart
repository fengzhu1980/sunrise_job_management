import 'package:cloud_firestore/cloud_firestore.dart';

class JobHazard {
  String id;
  String title;
  String description;
  List swms;
  DateTime createdAt;
  DateTime modifiedAt;
  bool isActive;
  final String relatedJobId;

  JobHazard({
    this.id,
    this.title,
    this.description,
    this.swms,
    this.createdAt,
    this.modifiedAt,
    this.isActive,
    this.relatedJobId,
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
      'relatedJobId': relatedJobId,
    };
  }

  static JobHazard fromSnapshot(DocumentSnapshot snapshot) {
    final returnHazard = JobHazard(
      id: snapshot.documentID,
      title: snapshot['title'],
      description: snapshot['description'],
      swms: List.from(snapshot['swms']),
      createdAt: DateTime.tryParse(snapshot['createdAt'].toDate().toString()),
      isActive: snapshot['isActive'],
      relatedJobId: snapshot['relatedJobId'],
    );

    if (snapshot['modifiedAt'] != null) {
      returnHazard.modifiedAt =
          DateTime.tryParse(snapshot['modifiedAt'].toString());
    }

    return returnHazard;
  }
}
