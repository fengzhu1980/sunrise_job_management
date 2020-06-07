import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:sunrise_job_management/widgets/public/date_time_picker.dart';
import '../../models/job.dart';

class JobForm extends StatefulWidget {
  @override
  _JobFormState createState() => _JobFormState();
}

class _JobFormState extends State<JobForm> {
  DateTime _fromDate = DateTime.now().add(Duration(days: 1));
  TimeOfDay _fromTime = const TimeOfDay(hour: 9, minute: 00);
  DateTime _toDate = DateTime.now().add(Duration(days: 1));
  TimeOfDay _toTime = const TimeOfDay(hour: 10, minute: 00);
  final GlobalKey<FormState> _jobFormKey = GlobalKey<FormState>();
  var _jobCode = 0;
  String _stage = '';
  List _tasks = [];
  String _userId = '';
  bool _isLoading = false;
  final _titleInputController = TextEditingController();
  final _addressInputController = TextEditingController();
  final _tasksInputController = TextEditingController();
  final _nameInputController = TextEditingController();
  final _emailInputController = TextEditingController();
  final _phoneInputController = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void _trySubmit() async {
    final isValid = _jobFormKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      _jobFormKey.currentState.save();

      // Save job
      final jobData = Job(
        code: (_jobCode + 1).toString(),
        title: _titleInputController.text.trim(),
        address: _addressInputController.text.trim(),
        stage: _stage,
        startDate: _fromDate.toString(),
        endDate: _toDate.toString(),
        startTime: _fromTime.format(context),
        endTime: _toTime.format(context),
        tasks: _tasks,
        createdAt: DateTime.now().toUtc().toString(),
        customerName: _nameInputController.text.trim(),
        customerEmail: _emailInputController.text.trim(),
        customerPhone: _phoneInputController.text.trim(),
        userId: _userId,
      );

      await Firestore.instance
          .collection('jobs')
          .document()
          .setData(jobData.toMap());

      // Add job code
      await Firestore.instance
          .collection('job_codes')
          .document()
          .setData({'code': int.parse(jobData.code)});

      scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Add job successed.'),
          backgroundColor: Colors.green,
          duration: Duration(milliseconds: 1500),
        ),
      );

      setState(() {
        _isLoading = true;
      });
      // final format = DateFormat.jm();
      // final time = TimeOfDay.fromDateTime(format.parse(jobData.startTime));
      // print(format);
      // print(time);
      print(jobData);
      print(jobData.code);
      print(jobData.title);
      print(jobData.address);
      print(jobData.stage);
      print(jobData.startDate);
      print(jobData.endDate);
      print(jobData.startTime);
      print(jobData.endTime);
      print(jobData.tasks);
      print(jobData.createdAt);
      print(jobData.customerName);
      print(jobData.customerEmail);
      print(jobData.customerPhone);
      print(jobData.userId);

      // await Firestore.instance
      //   .collection('jobs')
      //   .document()
      //   .setData()

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _titleInputController.dispose();
    _addressInputController.dispose();
    _tasksInputController.dispose();
    _nameInputController.dispose();
    _emailInputController.dispose();
    _phoneInputController.dispose();
  }

  String _emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  String _generalValidator(String value) {
    if (value.isEmpty) {
      return 'Please provide a value';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Create new job'),
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
              key: _jobFormKey,
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 14.0),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.work),
                        Text(
                          'Job Details',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder(
                    stream:
                        Firestore.instance.collection('job_codes').snapshots(),
                    builder: (ctx, codeSnapshot) {
                      if (!codeSnapshot.hasData) {
                        return const Text('Loading...');
                      }
                      final codeData = codeSnapshot.data.documents;
                      codeData.forEach((element) {
                        if (element['code'] > _jobCode) {
                          _jobCode = element['code'];
                        }
                      });
                      return Text(
                        'Job #${(_jobCode + 1)}',
                        style: Theme.of(context).textTheme.headline6,
                      );
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: 'Property Services Job',
                      // icon: Icon(Icons.assignment_turned_in),
                    ),
                    textCapitalization: TextCapitalization.words,
                    controller: _titleInputController,
                    minLines: 1,
                    maxLines: 2,
                    validator: _generalValidator,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Address',
                      // icon: Icon(Icons.location_on),
                    ),
                    minLines: 1,
                    maxLines: 2,
                    controller: _addressInputController,
                    validator: _generalValidator,
                  ),
                  StreamBuilder(
                    stream: Firestore.instance.collection('stages').snapshots(),
                    builder: (ctx, stageSnapshot) {
                      if (!stageSnapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final stagesData = stageSnapshot.data.documents;
                      return DropdownButtonFormField(
                        value:
                            ((stagesData as List<dynamic>).firstWhere((stage) {
                          return (stage['priority'] == '0');
                        }) as dynamic)['id'] as String,
                        validator: _generalValidator,
                        onSaved: (value) {
                          _stage = value;
                        },
                        onChanged: (value) {
                          _stage = value;
                        },
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          // filled: false,
                          labelText: 'Stage',
                          // icon: Icon(Icons.menu),
                        ),
                        items: (stagesData as List<dynamic>).map((value) {
                          return DropdownMenuItem(
                            value: value['id'].toString(),
                            child: Text(value['stage'].toString()),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  DateTimePicker(
                    labelText: 'From',
                    selectedDate: _fromDate,
                    selectedTime: _fromTime,
                    selectDate: (DateTime date) {
                      setState(() {
                        _fromDate = date;
                      });
                    },
                    selectTime: (TimeOfDay time) {
                      setState(() {
                        _fromTime = time;
                      });
                    },
                  ),
                  DateTimePicker(
                    labelText: 'To',
                    selectedDate: _toDate,
                    selectedTime: _toTime,
                    selectDate: (DateTime date) {
                      setState(() {
                        _toDate = date;
                      });
                    },
                    selectTime: (TimeOfDay time) {
                      setState(() {
                        _toTime = time;
                      });
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 14.0),
                    child: Text(
                      'Tasks',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  StreamBuilder(
                    stream: Firestore.instance.collection('tasks').snapshots(),
                    builder: (ctx, tasksSnapshot) {
                      if (!tasksSnapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final tasksData = tasksSnapshot.data.documents;
                      return Column(
                          children: (tasksData as List<dynamic>).map((task) {
                        return CheckboxListTile(
                          title: Text(task['task']),
                          value: _tasks.contains(task['id']),
                          onChanged: (bool value) {
                            setState(() {
                              if (value) {
                                if (!_tasks.contains(task['id'])) {
                                  _tasks.add(task['id']);
                                }
                              } else {
                                if (_tasks.contains(task['id'])) {
                                  _tasks.remove(task['id']);
                                }
                              }
                            });
                          },
                        );
                      }).toList());
                    },
                  ),
                  const Divider(
                    thickness: 2,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.0),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.contacts),
                        Text(
                          'Contact Details',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ],
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                    textCapitalization: TextCapitalization.words,
                    controller: _nameInputController,
                    validator: _generalValidator,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailInputController,
                    minLines: 1,
                    maxLines: 2,
                    validator: _emailValidator,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Phone',
                    ),
                    controller: _phoneInputController,
                    keyboardType: TextInputType.phone,
                    validator: _generalValidator,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.assignment_ind),
                        Text(
                          'Assign to',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder(
                    stream: Firestore.instance.collection('users').snapshots(),
                    builder: (ctx, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const Text('Loading');
                      }
                      final userData = userSnapshot.data.documents;
                      return DropdownButtonFormField(
                        value: ((userData as List<dynamic>).firstWhere((user) {
                          return (user['id'] != '0');
                        }) as dynamic)['id'] as String,
                        validator: _generalValidator,
                        onSaved: (value) {
                          _userId = value;
                        },
                        onChanged: (value) {
                          _userId = value;
                        },
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          // filled: false,
                          labelText: 'User',
                          // icon: Icon(Icons.menu),
                        ),
                        items: (userData as List<dynamic>).map((value) {
                          return DropdownMenuItem(
                            value: value['id'].toString(),
                            child: Text(value['username'].toString()),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  SizedBox(height: 12),
                  if (_isLoading)
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                  if (!_isLoading)
                    RaisedButton(
                      child: Text('Save Job'),
                      onPressed: _trySubmit,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Theme.of(context).primaryColor,
                      textColor:
                          Theme.of(context).primaryTextTheme.button.color,
                      elevation: 3,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
