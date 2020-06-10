import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// TODO Add created by, modified by
class Job {
  String id;
  int code;
  String title;
  String address;
  String stage;
  DateTime startDate;
  DateTime endDate;
  TimeOfDay startTime;
  TimeOfDay endTime;
  String createdAt;
  String modifiedAt;
  List tasks;
  String customerName;
  String customerEmail;
  String customerPhone;
  String customerId;
  String userId;
  bool isDeleted;

  Job({
    this.id,
    @required this.code,
    @required this.title,
    @required this.address,
    this.stage,
    @required this.startDate,
    @required this.endDate,
    this.startTime,
    this.endTime,
    this.createdAt,
    this.modifiedAt,
    @required this.tasks,
    @required this.customerName,
    @required this.customerEmail,
    @required this.customerPhone,
    this.customerId,
    this.userId,
    this.isDeleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'address': address,
      'stage': stage,
      'startDate': startDate.toString(),
      'endDate': endDate.toString(),
      'startTime': DateFormat.jm().parse(startTime.toString()).toString(),
      'endTime': DateFormat.jm().parse(endTime.toString()).toString(),
      'createdAt': createdAt,
      'modifiedAt': modifiedAt,
      'tasks': tasks,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'customerId': customerId,
      'userId': userId,
      'isDeleted': isDeleted
    };
  }

  static Job fromSnapshot(DocumentSnapshot snapshot) {
    return Job(
      id: snapshot.documentID,
      code: snapshot['code'],
      title: snapshot['title'],
      address: snapshot['address'],
      stage: snapshot['stage'],
      startDate: DateTime.parse(snapshot['startDate']),
      endDate: DateTime.parse(snapshot['endDate']),
      startTime: TimeOfDay.fromDateTime(DateFormat.jm().parse(snapshot['startTime'])),
      endTime: TimeOfDay.fromDateTime(DateFormat.jm().parse(snapshot['endTime'])),
      createdAt: snapshot['createdAt'],
      modifiedAt: snapshot['modifiedAt'],
      tasks: List.from(snapshot['tasks']),
      customerName: snapshot['customerName'],
      customerEmail: snapshot['customerEmail'],
      customerPhone: snapshot['customerPhone'],
      customerId: snapshot['customerId'],
      userId: snapshot['userId'],
      isDeleted: snapshot['isDeleted'],
    );
  }
}