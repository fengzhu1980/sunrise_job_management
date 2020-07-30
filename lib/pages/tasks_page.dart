import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/pages/edit_task_page.dart';
import 'package:sunrise_job_management/widgets/task/task_item.dart';

class TasksPage extends StatelessWidget {
  static const routeName = '/tasks';
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Task Management'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditTaskPage.routeName);
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('tasks')
            .orderBy('createdAt')
            .snapshots(),
        builder: (ctx, taskSnapshot) {
          if (taskSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (taskSnapshot.data.documents.length == 0) {
              return Center(
                child: Text('No Tasks'),
              );
            } else {
              return ListView.builder(
                itemCount: taskSnapshot.data.documents.length,
                itemBuilder: (_, i) => Column(
                  children: <Widget>[
                    TaskItem(
                      key: ValueKey(taskSnapshot.data.documents[i]['id']),
                      taskSnapshot: taskSnapshot.data.documents[i],
                      scaffoldKey: scaffoldKey,
                    ),
                  ],
                ),
              );
            }
          }
        },
      ),
    );
  }
}
