import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/enums/enum_file.dart';
import 'package:sunrise_job_management/models/task.dart';
import 'package:sunrise_job_management/pages/edit_task_page.dart';

class TaskItem extends StatefulWidget {
  final DocumentSnapshot taskSnapshot;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const TaskItem({
    Key key,
    this.taskSnapshot,
    this.scaffoldKey,
  }) : super(key: key);

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  Task _taskFromSnapshot;

  @override
  void initState() {
    super.initState();
    _taskFromSnapshot = Task.fromSnapshot(widget.taskSnapshot);
    print('create at: ${_taskFromSnapshot.createdAt}');
  }

  void _tryOperateTask(CommonOption option) async {
    try {
      bool isActive = false;
      var actionString = 'Inactive';
      if (option == CommonOption.Active) {
        isActive = true;
        actionString = 'Active';
      }
      final taskId = _taskFromSnapshot.id;
      await Firestore.instance
          .collection('tasks')
          .document(taskId)
          .updateData({'isActive': isActive}).then((_) => {
                widget.scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    content: Text('Task $actionString success.'),
                    backgroundColor: Colors.green,
                    duration: Duration(milliseconds: 2000),
                  ),
                ),
              });
      setState(() {
        _taskFromSnapshot = Task.fromSnapshot(widget.taskSnapshot);
      });
    } catch (e) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred.'),
          content: Text(e.toString()),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
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
          Icons.adjust,
          color: _taskFromSnapshot.isActive ? Colors.green : Colors.red,
        ),
        title: Text(_taskFromSnapshot.task),
        subtitle: Text(_taskFromSnapshot.price.toString()),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditTaskPage(_taskFromSnapshot),
          ));
        },
        trailing: PopupMenuButton<CommonOption>(
          onSelected: (CommonOption result) {
            switch (result) {
              case CommonOption.Modify:
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditTaskPage(_taskFromSnapshot),
                ));
                break;
              case CommonOption.Active:
                _tryOperateTask(CommonOption.Active);
                break;
              case CommonOption.Inactive:
                _tryOperateTask(CommonOption.Inactive);
                break;
              default:
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<CommonOption>>[
            const PopupMenuItem(
              value: CommonOption.Active,
              child: Text('Active'),
            ),
            const PopupMenuItem(
              value: CommonOption.Inactive,
              child: Text('Inactive'),
            ),
            const PopupMenuItem(
              value: CommonOption.Modify,
              child: Text('Modify'),
            ),
          ],
        ),
      ),
    );
  }
}
