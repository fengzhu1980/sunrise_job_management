import 'package:flutter/material.dart';

class User {
  final String id;
  final String avatar;
  final String createdAt;
  final String email;
  final bool isActive;
  final String username;
  final String phone;
  final List roles;

  User({
    @required this.id,
    this.avatar,
    @required this.createdAt,
    @required this.email,
    @required this.isActive,
    @required this.username,
    this.phone,
    @required this.roles,
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
      'roles': roles,
    };
  }
}
