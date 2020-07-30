import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/models/user.dart';
import 'package:sunrise_job_management/pages/edit_user_page.dart';
import 'package:sunrise_job_management/pages/hazards_page.dart';
import 'package:sunrise_job_management/pages/swms_page.dart';
import 'package:sunrise_job_management/pages/tasks_page.dart';
import 'package:sunrise_job_management/pages/users_page.dart';

import '../../pages/jobs_page.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer(this.userData);

  final User userData;
  @override
  Widget build(BuildContext context) {
    // print('aaaaa');
    print(userData);
    print(userData.email);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          AppBar(
            title: Text('Hello ${userData.username}'),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: const Icon(Icons.work),
            title: const Text('My jobs'),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          if (userData.roles.contains('admin'))
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Job Management'),
              onTap: () {
                Navigator.of(context).pushNamed(JobsPage.routeName);
              },
            ),
          if (userData.roles.contains('admin'))
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('User Management'),
              onTap: () {
                Navigator.of(context).pushNamed(UsersPage.routeName);
              },
            ),
          if (userData.roles.contains('admin'))
            ListTile(
              leading: Icon(Icons.group_work),
              title: Text('Task Management'),
              onTap: () {
                Navigator.of(context).pushNamed(TasksPage.routeName);
              },
            ),
          if (userData.roles.contains('admin'))
            ListTile(
              leading: Icon(Icons.warning),
              title: Text('Hazard Management'),
              onTap: () {
                Navigator.of(context).pushNamed(HazardsPage.routeName);
              },
            ),
          if (userData.roles.contains('admin'))
            ListTile(
              leading: Icon(Icons.insert_chart),
              title: Text('Swms Management'),
              onTap: () {
                Navigator.of(context).pushNamed(SwmsPage.routeName);
              },
            ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditUserPage(userData, true),
              ));
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
