import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/enums/enum_option.dart';
import 'package:sunrise_job_management/pages/edit_job_page.dart';

class JobItem extends StatelessWidget {
  final DocumentSnapshot jobSnapshot;

  JobItem(this.jobSnapshot);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.work),
        title: Text('#${jobSnapshot['code']} ${jobSnapshot['title']}'),
        subtitle: Text(jobSnapshot['customerName']),
        onTap: () {
          // Navigator.of(context).pushNamed(EditJobPage.routeName, arguments: jobSnapshot['id']);
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditJobPage(jobSnapshot)));
        },
        trailing: PopupMenuButton<Option>(
          onSelected: (Option result) {
            print(result);
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<Option>>[
            PopupMenuItem<Option>(
              // textStyle: Co,
              value: Option.Assign,
              child: Row(
                  children: <Widget>[
                    Icon(Icons.person_add),
                    Text('Assign'),
                  ],
                ),
            ),
            const PopupMenuItem<Option>(
              value: Option.Delete,
              child: Text('Delete'),
            ),
            const PopupMenuItem<Option>(
              value: Option.Modify,
              child: Text('Modify'),
            ),
          ],
        ),
// Icon(Icons.more_vert),
      ),
    );
  }
}
