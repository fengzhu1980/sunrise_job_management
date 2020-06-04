import 'package:flutter/material.dart';
import 'package:sunrise_job_management/widgets/public/app_drawer.dart';
import 'package:sunrise_job_management/widgets/public/top_bar.dart';

class JobsOverviewPage extends StatefulWidget {
  @override
  _JobsOverviewPageState createState() => _JobsOverviewPageState();
}

class _JobsOverviewPageState extends State<JobsOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar('Jobs'),
      drawer: AppDrawer(),
      body: Center(
        child: Container(
          child: Text('overview'),
        ),
      ),
    );
  }
}
