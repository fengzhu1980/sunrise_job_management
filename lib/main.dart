import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:sunrise_job_management/pages/auth_page.dart';
import 'package:sunrise_job_management/pages/edit_user_page.dart';
import 'package:sunrise_job_management/pages/jobs_overview_page.dart';
import 'package:sunrise_job_management/pages/splash_page.dart';
import 'package:sunrise_job_management/pages/jobs_page.dart';
import 'package:sunrise_job_management/pages/edit_job_page.dart';
import 'package:sunrise_job_management/pages/users_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sunrise Service',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (ctx, userSnapshot) {
          print('usersnapshot: $userSnapshot');
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return SplashPage();
          }
          if (userSnapshot.hasData) {
            return JobsOverviewPage(userSnapshot.data.uid);
          } else {
            return AuthPage();
          }
        },
      ),
      routes: {
        JobsPage.routeName: (ctx) => JobsPage(),
        EditJobPage.routeName: (ctx) => EditJobPage(),
        JobsOverviewPage.routeName: (ctx) => JobsOverviewPage(),
        UsersPage.routeName: (ctx) => UsersPage(),
        EditUserPage.routeName: (ctx) => EditUserPage(),
      },
    );
  }
}
