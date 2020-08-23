import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/widgets/job/job_item.dart';

class JobsReschedulePage extends StatefulWidget {
  static const routeName = '/jobs/reschedule';

  @override
  _JobsReschedulePageState createState() => _JobsReschedulePageState();
}

class _JobsReschedulePageState extends State<JobsReschedulePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Reschedule Job Management'),
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('jobs')
            .where('isRescheduled', isEqualTo: true)
            .where('hasBeenReassigned', isEqualTo: false)
            .orderBy('modifiedAt')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.data.documents.length == 0) {
              return Center(
                child: Text('No rescheduled job'),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (_, i) => Column(
                  children: [
                    JobItem(snapshot.data.documents[i], scaffoldKey),
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
