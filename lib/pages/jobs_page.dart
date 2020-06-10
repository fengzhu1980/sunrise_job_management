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
  Future _futureJobsData;

  Future getJobs() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection('jobs').getDocuments();
    return qn.documents;
  }

  @override
  void initState() {
    super.initState();
    _futureJobsData = getJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: FutureBuilder(
        future: _futureJobsData,
        builder: (ctx, jobsSnapshot) {
          if (jobsSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: jobsSnapshot.data.length,
            itemBuilder: (_, i) => Column(
              children: <Widget>[
                JobItem(jobsSnapshot.data[i]),
              ],
            ),
          );
        },
      ),
    );
  }
}
