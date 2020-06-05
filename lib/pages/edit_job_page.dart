import 'package:flutter/material.dart';

import '../widgets/job/job_form.dart';

class EditJobPage extends StatefulWidget {
  static const routeName = '/edit-job';

  @override
  _EditJobPageState createState() => _EditJobPageState();
}

class _EditJobPageState extends State<EditJobPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create new job'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {},
          )
        ],
      ),
      body: JobForm(),
    );
  }
}
