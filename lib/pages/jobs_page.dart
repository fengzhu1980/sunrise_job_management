import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/widgets/job/job_item.dart';
import 'package:sunrise_job_management/widgets/public/date_picker.dart';

import './edit_job_page.dart';

class JobsPage extends StatefulWidget {
  static const routeName = '/jobs';

  @override
  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _queryFormKey = GlobalKey<FormState>();
  // Future _futureJobsData;
  Stream _streamJobsData;
  String _queryKeyword;
  DateTime _queryStartDate = DateTime.now();
  DateTime _queryEndDate = DateTime.now();
  bool _queryIsDeleted = false;
  bool _queryIsCompleted = false;

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
    // _streamJobsData = _getJobs();
    _queryEndDate = DateTime.now();
    _queryStartDate = DateTime(
        _queryEndDate.year, _queryEndDate.month - 1, _queryEndDate.day);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getJobs();
  }

  void _getJobs() {
    if (_queryKeyword == null) {
      _queryKeyword = '';
    }
    var tempData = Firestore.instance
        .collection('jobs')
        // .where('title', arrayContains: _queryKeyword)
        // .where('title', isLessThan: _queryKeyword + 'z')
        .where('startDate', isGreaterThanOrEqualTo: _queryStartDate)
        .where('startDate', isLessThan: _queryEndDate)
        .where('isDeleted', isEqualTo: _queryIsDeleted)
        .where('isCompleted', isEqualTo: _queryIsCompleted)
        // .orderBy('createdAt')
        .snapshots();

    setState(() {
      _streamJobsData = tempData;
    });
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
        // stream: Firestore.instance
        //     .collection('jobs')
        //     .orderBy('createdAt')
        //     .snapshots(),
        stream: _streamJobsData,
        builder: (ctx, jobsSnapshot) {
          print(
              'jobsSnapshot.connectionState: ${jobsSnapshot.connectionState}');
          if (jobsSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildQueryForm(),
                  SizedBox(
                    height: 8.0,
                  ),
                  if (jobsSnapshot.data.documents.length == 0)
                    Center(
                      child: Text('No Jobs'),
                    ),
                  if (jobsSnapshot.data.documents.length != 0)
                    ListView.builder(
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: jobsSnapshot.data.documents.length,
                      itemBuilder: (_, i) => Column(
                        children: <Widget>[
                          JobItem(jobsSnapshot.data.documents[i], scaffoldKey),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildQueryForm() {
    return Form(
      key: _queryFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: TextFormField(
          //     decoration: InputDecoration(
          //       labelText: 'Keyword',
          //       hintText: 'Please input keyword',
          //     ),
          //     initialValue: _queryKeyword,
          //     onSaved: (newValue) => _queryKeyword = newValue,
          //   ),
          // ),
          DatePicker(
            labelText: 'From',
            selectedDate: _queryStartDate,
            selectDate: (value) {
              setState(() {
                _queryStartDate = value;
              });
            },
          ),
          DatePicker(
            labelText: 'To',
            selectedDate: _queryEndDate,
            selectDate: (value) {
              setState(() {
                _queryEndDate = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Is Completed'),
            value: _queryIsCompleted,
            onChanged: (bool value) {
              setState(() {
                _queryIsCompleted = value;
              });
            },
            secondary: const Icon(Icons.done_outline),
          ),
          SwitchListTile(
            title: const Text('Is Deleted'),
            value: _queryIsDeleted,
            onChanged: (bool value) {
              setState(() {
                _queryIsDeleted = value;
              });
            },
            secondary: const Icon(Icons.delete),
          ),
          Center(
            child: RaisedButton(
              child: Text('Search'),
              onPressed: _getJobs,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).primaryTextTheme.button.color,
              elevation: 8,
            ),
          ),
        ],
      ),
    );
  }
}
