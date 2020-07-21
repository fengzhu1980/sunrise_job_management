import 'package:flutter/material.dart';
import 'package:sunrise_job_management/models/job.dart';

class JobDetailsPage extends StatefulWidget {
  static const routeName = '/job/details';
  final Job job;

  const JobDetailsPage(this.job);

  @override
  _JobDetailsPageState createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Details'),
      ),
      body: Center(
        child: Text(widget.job.title),
      ),
    );
  }
}
