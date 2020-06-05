import 'package:flutter/material.dart';
import 'package:sunrise_job_management/models/user.dart';

import '../../pages/jobs_page.dart';
import '../../pages/jobs_overview_page.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer(this.userData);

  final dynamic userData;
  @override
  Widget build(BuildContext context) {
    print('aaaaa');
    print(userData);
    print(userData['email']);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          AppBar(
            title: Text('Hello ${userData['username']}!'),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: const Icon(Icons.work),
            title: const Text('My jobs'),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('Job Management'),
            onTap: () {
              Navigator.of(context).pushNamed(JobsPage.routeName);
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('User Management'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
          ),
        ],
      ),
    );
  }
}
