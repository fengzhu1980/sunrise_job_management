import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/enums/enum_file.dart';
import 'package:sunrise_job_management/pages/edit_job_page.dart';

class JobItem extends StatefulWidget {
  final DocumentSnapshot jobSnapshot;
  final GlobalKey<ScaffoldState> scaffoldKey;

  JobItem(this.jobSnapshot, this.scaffoldKey);

  @override
  _JobItemState createState() => _JobItemState();
}

class _JobItemState extends State<JobItem> {

  void _showDeleteDialog() async {
    final jobCode = widget.jobSnapshot['code'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('CONFIRMATION'),
          content: Text('Are you sure to delete job $jobCode?'),
          actions: [
            RaisedButton(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              color: Colors.grey,
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            RaisedButton(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              color: Colors.red,
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                _tryDeleteJob();
                Navigator.pop(context);
              }
            ),
          ],
        );
      },
    );
  }

  void _tryDeleteJob() async {
    try {
      final jobId = widget.jobSnapshot['id'];
      await Firestore.instance
        .collection('jobs')
        .document(jobId)
        .updateData({'isDeleted': true})
        .then((_) => {
          widget.scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text('Job delete successfully.'),
              backgroundColor: Colors.green,
              duration: Duration(milliseconds: 1500),
            ),
          )
        });
    } catch (err) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text(err.toString()),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.work,
          color: widget.jobSnapshot['isDeleted'] ? Colors.red : Colors.green,
        ),
        title: Text(
            '#${widget.jobSnapshot['code']} ${widget.jobSnapshot['title']}'),
        subtitle: Text(widget.jobSnapshot['customerName']),
        onTap: () {
          // Navigator.of(context).pushNamed(EditJobPage.routeName, arguments: jobSnapshot['id']);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EditJobPage(widget.jobSnapshot)));
        },
        trailing: PopupMenuButton<JobOption>(
          onSelected: (JobOption result) {
            switch (result) {
              case JobOption.Modify:
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => EditJobPage(widget.jobSnapshot)));
                break;
              case JobOption.Delete:
                _showDeleteDialog();
                break;
              default:
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<JobOption>>[
            PopupMenuItem<JobOption>(
              // textStyle: Co,
              value: JobOption.Assign,
              child: Row(
                children: <Widget>[
                  Icon(Icons.person_add),
                  Text('Assign'),
                ],
              ),
            ),
            const PopupMenuItem<JobOption>(
              value: JobOption.Delete,
              child: Text('Delete'),
            ),
            const PopupMenuItem<JobOption>(
              value: JobOption.Modify,
              child: Text('Modify'),
            ),
          ],
        ),
// Icon(Icons.more_vert),
      ),
    );
  }
}
