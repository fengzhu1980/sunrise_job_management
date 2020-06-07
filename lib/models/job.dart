import 'package:flutter/material.dart';

class Job {
  String id;
  String code;
  String title;
  String address;
  String stage;
  String startDate;
  String endDate;
  String startTime;
  String endTime;
  String createdAt;
  List tasks;
  String customerName;
  String customerEmail;
  String customerPhone;
  String customerId;
  String userId;

  Job({
    @required this.code,
    @required this.title,
    @required this.address,
    this.stage = 'upcoming',
    @required this.startDate,
    @required this.endDate,
    this.startTime,
    this.endTime,
    @required this.createdAt,
    @required this.tasks,
    @required this.customerName,
    @required this.customerEmail,
    @required this.customerPhone,
    this.customerId,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'title': title,
      'address': address,
      'stage': stage,
      'startDate': startDate,
      'endDate': endDate,
      'startTime': startTime,
      'endTime': endTime,
      'createdAt': createdAt,
      'tasks': tasks,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'customerId': customerId,
      'userId': userId,
    };
  }
}