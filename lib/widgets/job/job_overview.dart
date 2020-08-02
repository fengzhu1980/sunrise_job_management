import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sunrise_job_management/models/job.dart';
import 'package:sunrise_job_management/models/task.dart';
import 'package:sunrise_job_management/widgets/note/note_item.dart';
import 'package:url_launcher/url_launcher.dart';

class JobOverview extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Job job;
  final List<Task> tasks;
  final Map<String, String> stages;

  const JobOverview(this.scaffoldKey, this.job, this.tasks, this.stages);

  @override
  _JobOverviewState createState() => _JobOverviewState();
}

class _JobOverviewState extends State<JobOverview> {
  String _username = '';
  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  void _getUserName() async {
    var userRef = await Firestore.instance
        .collection('users')
        .document(widget.job.userId)
        .get();
    setState(() {
      _username = userRef['username'];
    });
  }

  // Launch URL
  _launchURL(String str) async {
    var url = 'https://www.google.com/maps/search/?api=1&query=$str';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Launch URL
  _launchPhone(String str) async {
    var url = 'tel:$str';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildJobOverview(),
          _buildJobDetails(),
          _buildMainContact(),
          NoteItem(widget.scaffoldKey, widget.job),
        ],
      ),
    );
  }

  Widget _buildJobOverview() {
    // var date = DateTime.now();
    // print(date.toString()); // prints something like 2019-12-10 10:02:22.287949
    // print(DateFormat('EEEE').format(date)); // prints Tuesday
    // print(DateFormat('EEEE, d MMM, yyyy').format(date)); // prints Tuesday, 10 Dec, 2019
    // print(DateFormat('h:mm a').format(date)); // prints 10:02 AM
    final tempDate = DateFormat('EEEE d MMMM').format(widget.job.startDate);
    final tempStartTime = widget.job.startTime.format(context);
    final tempEndTime = widget.job.endTime.format(context);
    return Card(
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.alarm),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    widget.stages[widget.job.stage],
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                    'Job scheduled at $tempDate $tempStartTime to $tempEndTime for $_username.'),
              ),
              Divider(),
              Row(
                children: <Widget>[
                  Icon(Icons.list),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    'Job Tasks',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
              DataTable(
                columns: <DataColumn>[
                  DataColumn(
                    label: Text(
                      'Description',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Hours',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Price',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
                rows: widget.job.tasks.map((taskId) {
                  final tempTask = widget.tasks
                      .firstWhere((element) => element.id == taskId);
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(Text('${tempTask.task}')),
                      DataCell(Text('${tempTask.hours}')),
                      DataCell(Text('${tempTask.price}')),
                    ],
                  );
                }).toList(),
              ),
            ],
          )),
    );
  }

  Widget _buildJobDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.work),
                SizedBox(
                  width: 4,
                ),
                Text(
                  'Job Details',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Title'),
                  Divider(
                    height: 2,
                    thickness: 1,
                  ),
                  Text(widget.job.title),
                ],
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              children: <Widget>[
                Icon(Icons.location_on),
                SizedBox(
                  width: 4,
                ),
                Text(
                  'Site Address',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ],
            ),
            FlatButton(
              padding: EdgeInsets.all(0.0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              child: Text(
                widget.job.address,
                style: TextStyle(
                  fontSize: 17.0,
                  color: Colors.lightBlue,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onPressed: () => _launchURL(widget.job.address),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMainContact() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.perm_contact_calendar),
                SizedBox(
                  width: 4,
                ),
                Text(
                  'Main Contact',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Name'),
                  Divider(
                    height: 1,
                    thickness: 1,
                  ),
                  Text(widget.job.customerName),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Email'),
                  Divider(
                    height: 1,
                    thickness: 1,
                  ),
                  Text(widget.job.customerEmail),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Phone'),
                  Divider(
                    height: 1,
                    thickness: 1,
                  ),
                  FlatButton(
                    padding: EdgeInsets.all(0.0),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    child: Text(
                      widget.job.customerPhone,
                      style: TextStyle(
                        fontSize: 17.0,
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onPressed: () => _launchPhone(widget.job.customerPhone),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
