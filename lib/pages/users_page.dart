import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/pages/edit_user_page.dart';
import 'package:sunrise_job_management/widgets/user/user_item.dart';

class UsersPage extends StatefulWidget {
  static const routeName = '/users';

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditUserPage.routeName);
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (ctx, usersSnapshot) {
          if (usersSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (usersSnapshot.data.documents.length == 0) {
              return Center(
                child: Text('No users'),
              );
            } else {
              return ListView.builder(
                itemCount: usersSnapshot.data.documents.length,
                itemBuilder: (_, i) => Column(
                  children: [
                    UserItem(usersSnapshot.data.documents[i], scaffoldKey),
                  ],
                ),
              );
            }
          }
        },
      ),
    );
  }
}
