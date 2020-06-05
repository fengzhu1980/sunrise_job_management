import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:sunrise_job_management/widgets/public/app_drawer.dart';
import 'package:sunrise_job_management/widgets/public/top_bar.dart';

class JobsOverviewPage extends StatelessWidget {
  static const routeName = '/jobs_overview';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser(),
      builder: (ctx, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return StreamBuilder(
            stream: Firestore.instance.collection('users').document(futureSnapshot.data.uid).snapshots(),
            builder: (ctx, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final userData = userSnapshot.data;
              return Scaffold(
                appBar: TopBar('My Jobs'),
                drawer: AppDrawer(userData),
                body: Center(
                  child: Container(
                    child: Text('overview'),
                  ),
                ),
              );
            });
      },
    );
  }
}
