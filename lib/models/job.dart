import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// TODO Add modified by
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
  DateTime startDateReal;
  DateTime endDateReal;
  TimeOfDay startTimeReal;
  TimeOfDay endTimeReal;
  // int startHour;
  // int startMin;
  // int endHour;
  // int endMin;
  DateTime createdAt;
  DateTime modifiedAt;
  List tasks;
  String customerName;
  String customerEmail;
  String customerPhone;
  String customerId;
  String userId;
  bool isDeleted = false;
  String note;
  String createdBy;
  String modifiedBy;
  List hazards;
  String exteriorPhoto;
  List beforePhotos;
  bool isRescheduled;
  bool hasBeenReassigned;
  List completedTasks;
  String rescheduleReason;
  DateTime originalStartDate;
  DateTime originalEndDate;
  TimeOfDay originalStartTime;
  TimeOfDay originalEndTime;

  Job({
    this.id,
    @required this.code,
    @required this.title,
    @required this.address,
    this.stage,
    @required this.startDate,
    @required this.endDate,
    // this.startHour,
    // this.startMin,
    // this.endHour,
    // this.endMin,
    this.startTime,
    this.endTime,
    this.startDateReal,
    this.endDateReal,
    this.startTimeReal,
    this.endTimeReal,
    this.createdAt,
    this.modifiedAt,
    @required this.tasks,
    @required this.customerName,
    @required this.customerEmail,
    @required this.customerPhone,
    this.customerId,
    this.userId,
    this.isDeleted,
    this.note,
    this.createdBy,
    this.modifiedBy,
    this.hazards,
    this.exteriorPhoto,
    this.beforePhotos,
    this.isRescheduled,
    this.hasBeenReassigned,
    this.completedTasks,
    this.rescheduleReason,
    this.originalStartDate,
    this.originalEndDate,
    this.originalStartTime,
    this.originalEndTime,
  });

  Map<String, dynamic> toMap() {
    final returnJob = {
      'id': id,
      'code': code,
      'title': title,
      'address': address,
      'stage': stage,
      'startDate': startDate.toUtc(),
      'startHour': startTime.hour,
      'startMin': startTime.minute,
      // 'startTime': DateTime(startDate.toUtc().year, startDate.month, startTime.hour, startTime.minute).toString(),
      'endDate': endDate.toUtc(),
      'endHour': endTime.hour,
      'endMin': endTime.minute,
      'startDateReal': startDateReal?.toUtc(),
      'endDateReal': endDateReal?.toUtc(),
      // TODO: delete real start hour and min, end hour and min real properties. and snapshot func as well.
      // TODO: check utc time
      'startHourReal': startTimeReal?.hour,
      'startMinReal': startTimeReal?.minute,
      'endHourReal': endTimeReal?.hour,
      'endMinReal': endTimeReal?.minute,
      // 'endTime': DateTime(endDate.year, endDate.month, endTime.hour, endTime.minute).toString(),
      // 'startTime': DateFormat.jm().parse(startTime.toString()).toString(),
      // 'startTime': DateFormat.jm().parse(startTime.toString()).toString(),
      // 'endTime': DateFormat.jm().parse(endTime.toString()).toString(),
      // 'endTime': DateFormat.jm().parse(endTime.toString()).toString(),
      'createdAt': createdAt,
      'modifiedAt': modifiedAt,
      'tasks': tasks,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'customerId': customerId,
      'userId': userId,
      'isDeleted': isDeleted,
      'note': note,
      'createdBy': createdBy,
      'modifiedBy': modifiedBy,
      'hazards': hazards,
      'exteriorPhoto': exteriorPhoto,
      'beforePhotos': beforePhotos,
      'isRescheduled': isRescheduled,
      'hasBeenReassigned': hasBeenReassigned,
      'completedTasks': completedTasks,
      'rescheduleReason': rescheduleReason,
      'originalStartDate': originalStartDate,
      'originalEndDate': originalEndDate,
      'originalStartHour': originalStartTime.hour,
      'originalStartMin': originalStartTime.minute,
      'originalEndHour': originalEndTime.hour,
      'originalEndMin': originalEndTime.minute,
    };
    // if (startDate != null) {
    //   returnJob['startDate'] = _getDateTimeDate(startDate.toUtc());
    // }
    // if (endDate != null) {
    //   returnJob['endDate'] = _getDateTimeDate(endDate.toUtc());
    // }
    // if (startDateReal != null) {
    //   returnJob['startDateReal'] = _getDateTimeDate(startDateReal.toUtc());
    // }
    // if (endDateReal != null) {
    //   returnJob['endDateReal'] = _getDateTimeDate(endDateReal.toUtc());
    // }
    return returnJob;
  }

  static Job fromSnapshot(DocumentSnapshot snapshot) {
    final returnJob = Job(
      id: snapshot.documentID,
      code: snapshot['code'],
      title: snapshot['title'],
      address: snapshot['address'],
      stage: snapshot['stage'],
      startDate: DateTime.tryParse(snapshot['startDate'].toDate().toString()),
      endDate: DateTime.tryParse(snapshot['endDate'].toDate().toString()),
      startTime:
          TimeOfDay(hour: snapshot['startHour'], minute: snapshot['startMin']),
      endTime: TimeOfDay(hour: snapshot['endHour'], minute: snapshot['endMin']),
      // startDateReal: DateTime.tryParse(snapshot['startDateReal']?.toString()),
      // endDateReal: DateTime.tryParse(snapshot['endDateReal']?.toString()),
      // startTimeReal: TimeOfDay(hour: snapshot['startHourReal'], minute: snapshot['startMinReal']),
      // endTimeReal: TimeOfDay(hour: snapshot['endHourReal'], minute: snapshot['endMinReal']),
      createdAt: DateTime.tryParse(snapshot['createdAt'].toDate().toString()),
      // modifiedAt: DateTime.tryParse(snapshot['modifiedAt']?.toString()),
      tasks: List.from(snapshot['tasks']),
      customerName: snapshot['customerName'],
      customerEmail: snapshot['customerEmail'],
      customerPhone: snapshot['customerPhone'],
      customerId: snapshot['customerId'],
      userId: snapshot['userId'],
      isDeleted: snapshot['isDeleted'],
      note: snapshot['note'],
      createdBy: snapshot['createdBy'],
      modifiedBy: snapshot['modifiedBy'],
      hazards: snapshot['hazards'],
      exteriorPhoto: snapshot['exteriorPhoto'],
      beforePhotos: snapshot['beforePhotos'],
      isRescheduled: snapshot['isRescheduled'],
      hasBeenReassigned: snapshot['hasBeenReassigned'],
      completedTasks: snapshot['completedTasks'],
      rescheduleReason: snapshot['rescheduleReason'],
    );
    if (snapshot['startDateReal'] != null) {
      returnJob.startDateReal =
          DateTime.tryParse(snapshot['startDateReal'].toDate().toString());
    }
    if (snapshot['endDateReal'] != null) {
      returnJob.endDateReal =
          DateTime.tryParse(snapshot['endDateReal'].toDate().toString());
    }
    if ((snapshot['startHourReal'] != null) &&
        (snapshot['startMinReal'] != null)) {
      returnJob.startTimeReal = TimeOfDay(
          hour: snapshot['startHourReal'], minute: snapshot['startMinReal']);
    }
    if ((snapshot['endHourReal'] != null) && (snapshot['endMinReal'] != null)) {
      returnJob.startTimeReal = TimeOfDay(
          hour: snapshot['endHourReal'], minute: snapshot['endMinReal']);
    }
    if (snapshot['modifiedAt'] != null) {
      returnJob.modifiedAt =
          DateTime.tryParse(snapshot['modifiedAt'].toString());
    }
    if (snapshot['originalStartDate'] != null) {
      returnJob.originalStartDate =
          DateTime.tryParse(snapshot['originalStartDate'].toDate().toString());
    }
    if (snapshot['originalEndDate'] != null) {
      returnJob.originalEndDate =
          DateTime.tryParse(snapshot['originalEndDate'].toDate().toString());
    }
    if ((snapshot['originalStartHour'] != null) &&
        (snapshot['originalStartMin'] != null)) {
      returnJob.originalStartTime = TimeOfDay(
          hour: snapshot['originalStartHour'],
          minute: snapshot['originalStartMin']);
    }
    if ((snapshot['originalEndHour'] != null) &&
        (snapshot['originalEndMin'] != null)) {
      returnJob.originalEndTime = TimeOfDay(
          hour: snapshot['originalEndHour'],
          minute: snapshot['originalEndMin']);
    }
    return returnJob;
  }

  DateTime _getDateTimeDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}
