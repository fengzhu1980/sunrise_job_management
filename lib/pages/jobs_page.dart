import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/widgets/job/job_item.dart';

import './edit_job_page.dart';

class JobsPage extends StatefulWidget {
  static const routeName = '/jobs';

  @override
  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  // Future _futureJobsData;

  // For future builder
  // Future getJobs() async {
  //   var firestore = Firestore.instance;
  //   QuerySnapshot qn = await firestore.collection('jobs').getDocuments();
  //   return qn.documents;
  // }

  @override
  void initState() {
    super.initState();
    // For future builder
    // _futureJobsData = getJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Job Management'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditJobPage.routeName);
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('jobs').orderBy('createdAt').snapshots(),
        builder: (ctx, jobsSnapshot) {
          if (jobsSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
              itemCount: jobsSnapshot.data.documents.length,
              itemBuilder: (_, i) => Column(
                children: <Widget>[
                  JobItem(jobsSnapshot.data.documents[i], scaffoldKey),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
