import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/models/swms.dart';
import 'package:sunrise_job_management/models/task.dart';

class EditTaskPage extends StatefulWidget {
  static const routeName = '/edit-task';
  final Task taskData;

  EditTaskPage([this.taskData]);

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var _appBarTitle = 'Create new task';
  final GlobalKey<FormState> _taskFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Task _editTask = Task(
    id: null,
    price: 0,
    task: '',
    isActive: true,
  );

  @override
  void initState() {
    super.initState();
    if (widget.taskData != null) {
      _appBarTitle = 'Edit task';
      _editTask = widget.taskData;
    }
  }

  void _trySubmit() async {
    final isValid = _taskFormKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      setState(() {
        _isLoading = true;
      });

      _taskFormKey.currentState.save();

      var _operationType = 'Add';
      var _isSuccess = false;
      if (_editTask.id == null) {
        // Add task
        _editTask.createdAt = DateTime.now().toUtc();
        _editTask.isActive = true;

        try {
          DocumentReference taskRef =
              Firestore.instance.collection('tasks').document();
          _editTask.id = taskRef.documentID;
          await taskRef.setData(_editTask.toMap());
          _isSuccess = true;
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
        setState(() {
          _isLoading = false;
        });
      } else {
        // Update task
        _operationType = 'Update';
        await Firestore.instance
            .collection('tasks')
            .document(_editTask.id)
            .updateData(_editTask.toMap());
        _isSuccess = true;

        setState(() {
          _isLoading = false;
        });
      }

      if (_isSuccess) {
        scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text('$_operationType task successed.'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 2000),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(_appBarTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _trySubmit,
          )
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Card(
          margin: const EdgeInsets.all(9),
          elevation: 8.0,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _taskFormKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.work),
                          Text(
                            'Task Details',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ],
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Task',
                        hintText: 'Task name',
                      ),
                      textCapitalization: TextCapitalization.words,
                      initialValue: _editTask.task,
                      minLines: 1,
                      maxLines: 2,
                      onSaved: (value) {
                        _editTask.task = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please input a value';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Price',
                        hintText: 'Task Price',
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _editTask.price.toStringAsFixed(2),
                      onSaved: (value) {
                        _editTask.price = double.parse(value);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a price.';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number.';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please enter a number greater than zero.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    if (_isLoading)
                      Center(
                        child: CircularProgressIndicator(),
                      ),
                    if (!_isLoading)
                      Center(
                        child: RaisedButton(
                          child: Text('Save Task'),
                          onPressed: _trySubmit,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: Theme.of(context).primaryColor,
                          textColor:
                              Theme.of(context).primaryTextTheme.button.color,
                          elevation: 3,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
