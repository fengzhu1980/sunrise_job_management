import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String _code = '';
  String _stage = '';
  List _tasks = [];
  bool _isLoading = false;
  final _titleInputController = TextEditingController();
  final _addressInputController = TextEditingController();
  final _tasksInputController = TextEditingController();
  bool _test = false;

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
        code: 'abc0006',
        title: _titleInputController.text.trim(),
        address: _addressInputController.text.trim(),
        stage: _stage,
        startDate: _fromDate.toString(),
        endDate: _toDate.toString(),
        startTime: _fromTime.toString(),
        endTime: _toTime.toString(),
        tasks: _tasks,
        createdAt: DateTime.now().toUtc().toString(),
      );

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
    return Card(
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
              Text('#84349'),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Property Services Job',
                  // icon: Icon(Icons.assignment_turned_in),
                ),
                controller: _titleInputController,
                textInputAction: TextInputAction.next,
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
                textInputAction: TextInputAction.next,
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
                    value: ((stagesData as List<dynamic>).firstWhere((stage) {
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
              SizedBox(height: 12),
              if (_isLoading)
                CircularProgressIndicator(),
              if (!_isLoading)
                RaisedButton(
                  child: Text('Save Job'),
                  onPressed: _trySubmit,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).primaryTextTheme.button.color,
                  elevation: 3,
                ),
              // StreamBuilder(
              //     stream: Firestore.instance
              //         .collection('stages')
              //         // .document(futureSnapshot.data.uid)
              //         .snapshots(),
              //     builder: (ctx, userSnapshot) {
              //       if (userSnapshot.connectionState ==
              //           ConnectionState.waiting) {
              //         return Center(
              //           child: CircularProgressIndicator(),
              //         );
              //       }
              //       final userData = userSnapshot.data.documents;
              //       return FormField<String>(
              //         builder: (FormFieldState<String> state) {
              //           return InputDecorator(
              //             decoration: InputDecoration(
              //               labelText: 'Stage',
              //               hintText: 'Please select stage',
              //             ),
              //             isEmpty: false,
              //             child: DropdownButtonHideUnderline(
              //               child: DropdownButton<String>(
              //                 value: _jobData.stage,
              //                 isDense: true,
              //                 onChanged: (value) {
              //                   setState(() {
              //                     _jobData.stage = value;
              //                   });
              //                 },
              //                 items: (userData as List<dynamic>).map((value) {
              //                   return DropdownMenuItem(
              //                     value: value['stage'].toString(),
              //                     child: Text(value['stage'].toString()),
              //                   );
              //                 }).toList(),
              //               ),
              //             ),
              //           );
              //         },
              //       );
              //     }),
            ],
          ),
        ),
      ),
    );
  }
}
