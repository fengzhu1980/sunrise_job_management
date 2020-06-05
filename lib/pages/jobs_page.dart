import 'package:flutter/material.dart';

import './edit_job_page.dart';

class JobsPage extends StatelessWidget {
  static const routeName = '/jobs';

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
      body: Center(
        child: Text('All jobs'),
      ),
    );
  }
}
