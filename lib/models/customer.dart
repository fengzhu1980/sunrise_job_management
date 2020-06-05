import 'package:flutter/material.dart';

class Customer {
  final String id;
  final String firstName;
  final String lastName;
  final String customerType;
  final String email;
  final String phone;
  final String phoneType;
  final String address;
  final String createdAt;

  Customer({
    @required this.id,
    @required this.firstName,
    @required this.lastName,
    this.customerType,
    @required this.email,
    @required this.phoneType,
    @required this.phone,
    this.address,
    @required this.createdAt
  });

  Map<String, dynamic> topMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'type': customerType,
      'email': email,
      'phoneType': phoneType,
      'phone': phone,
      'address': address,
      'createdAt': createdAt
    };
  }
}
