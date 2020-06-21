import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {
  final String id;
  String avatar;
  DateTime createdAt;
  String email;
  bool isActive;
  String username;
  String password;
  String phone;
  String firstName;
  String middleName;
  String lastName;
  List roles;
  String createdByUserId;
  DateTime modifiedAt;
  String modifiedByUserId;

  User({
    @required this.id,
    this.avatar,
    this.createdAt,
    @required this.email,
    @required this.isActive,
    @required this.username,
    this.password,
    this.phone,
    this.firstName,
    this.middleName,
    this.lastName,
    @required this.roles,
    this.createdByUserId,
    this.modifiedAt,
    this.modifiedByUserId
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'avatar': avatar,
      'createdAt': createdAt,
      'email': email,
      'isActive': isActive,
      'username': username,
      'phone': phone,
      'password': password,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'roles': roles,
      'createdByUserId': createdByUserId,
      'modifiedAt': modifiedAt,
      'modifiedByUserId': modifiedByUserId,
    };
  }

  static User fromSnapshot(DocumentSnapshot snapshot) {
    final returnUser = User(
      id: snapshot.documentID,
      avatar: snapshot['avatar'],
      createdAt: DateTime.tryParse(snapshot['createdAt'].toDate().toString()),
      email: snapshot['email'],
      isActive: snapshot['isActive'],
      username: snapshot['username'],
      phone: snapshot['phone'],
      firstName: snapshot['firstName'],
      middleName: snapshot['middleName'],
      lastName: snapshot['lastName'],
      roles: snapshot['roles'],
      createdByUserId: snapshot['createdByUserId'],
      modifiedByUserId: snapshot['modifiedByUserId'],
    );
    if (snapshot['modifiedAt'] != null) {
      returnUser.modifiedAt = DateTime.tryParse(snapshot['modifiedAt'].toString());
    }

    return returnUser;
  }
}
