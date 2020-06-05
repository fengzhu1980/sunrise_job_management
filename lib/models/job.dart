import 'package:flutter/material.dart';

class Job {
  final String id;
  final String code;
  final String title;
  final String address;
  String stage;
  final String serviceDate;
  final String startDateTime;
  final String endDateTime;
  final String createdAt;
  final List tasks;
  final String customerId;

  Job({
    @required this.id,
    @required this.code,
    @required this.title,
    @required this.address,
    this.stage = 'upcoming',
    @required this.serviceDate,
    this.startDateTime,
    this.endDateTime,
    @required this.createdAt,
    @required this.tasks,
    @required this.customerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'address': address,
      'stage': stage,
      'serviceDate': serviceDate,
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
      'createdAt': createdAt,
      'tasks': tasks,
      'customerId': customerId,
    };
  }
}