import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:sunrise_job_management/models/job.dart';
import 'package:sunrise_job_management/widgets/public/date_time_picker.dart';

class EditJobPage extends StatefulWidget {
  static const routeName = '/edit-job';
  final DocumentSnapshot jobData;

  EditJobPage([this.jobData]);

  @override
  _EditJobPageState createState() => _EditJobPageState();
}

class _EditJobPageState extends State<EditJobPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Job _editJob = Job(
    id: null,
    code: 0,
    title: '',
    address: '',
    stage: '',
    startDate: DateTime.now().add(Duration(days: 1)),
    endDate: DateTime.now().add(Duration(days: 1)),
    startTime: const TimeOfDay(hour: 9, minute: 00),
    endTime: const TimeOfDay(hour: 10, minute: 00),
    tasks: [],
    customerName: '',
    customerEmail: '',
    customerPhone: '',
    userId: ''
  );
  var _appBarTitle = 'Create new job';
  final GlobalKey<FormState> _jobFormKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // final initJobData = ModalRoute.of(context).settings.arguments as DocumentSnapshot;
    print(widget.jobData == null);
    if (widget.jobData != null) {
      _appBarTitle = 'Edit job';
      _editJob = Job.fromSnapshot(widget.jobData);
    }
  }

  void _trySubmit() async {
    final isValid = _jobFormKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      _jobFormKey.currentState.save();

      // Save job
      // final jobData = Job(
      //   code: _initValues['code'].toString(),
      //   // title: _initValues['title'].trim(),
      //   // address: _initValues['address'].trim(),
      //   stage: _initValues['stage'],
      //   startDate: _initValues['startDate'].toString(),
      //   endDate: _initValues['endDate'].toString(),
      //   // startTime: _initValues['startTime'].format(context),
      //   // endTime: _initValues['endTime'].format(context),
      //   tasks: _initValues['tasks'],
      //   createdAt: DateTime.now().toUtc().toString(),
      //   // customerName: _initValues['customerName'].trim(),
      //   // customerEmail: _initValues['customerEmail'].trim(),
      //   // customerPhone: _initValues['customerPhone'].trim(),
      //   userId: _userId,
      // );

      var oprationType = 'Add';
      if (_editJob.id == null) {
        // Add job
        _editJob.createdAt = DateTime.now().toUtc().toString();
        DocumentReference jobRef =
            Firestore.instance.collection('jobs').document();
        _editJob.id = jobRef.documentID;
        await jobRef.setData(_editJob.toMap());

        // Add job code
        await Firestore.instance
            .collection('job_codes')
            .document()
            .setData({'code':_editJob.code});
      } else {
        // Update job
        oprationType = 'Update';
        _editJob.modifiedAt = DateTime.now().toUtc().toString();
      }

      scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('$oprationType job successed.'),
          backgroundColor: Colors.green,
          duration: Duration(milliseconds: 1500),
        ),
      );

      setState(() {
        _isLoading = true;
      });
      // final format = DateFormat.jm();
      // final time = TimeOfDay.fromDateTime(format.parse(jobData.startTime));

      setState(() {
        _isLoading = false;
      });
    }
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
                  if (_editJob.id == null)
                    StreamBuilder(
                      stream: Firestore.instance
                          .collection('job_codes')
                          .snapshots(),
                      builder: (ctx, codeSnapshot) {
                        if (!codeSnapshot.hasData) {
                          return const Text('Loading...');
                        }
                        final codeData = codeSnapshot.data.documents;
                        codeData.forEach((element) {
                          print(element['code']);
                          print(_editJob.code);
                          if (element['code'] >= _editJob.code) {
                            _editJob.code = element['code'] + 1;
                          }
                        });
                        return Text(
                          'Job #${_editJob.code}',
                          style: Theme.of(context).textTheme.headline6,
                        );
                      },
                    ),
                  if (_editJob.id != null)
                    Text(
                      _editJob.code.toString(),
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: 'Property Services Job',
                      // icon: Icon(Icons.assignment_turned_in),
                    ),
                    textCapitalization: TextCapitalization.words,
                    initialValue: _editJob.title,
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
                    initialValue: _editJob.address,
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
                      var initStage = stagesData.firstWhere((stage) => stage['priority'] == '0')['id'] as String;
                      if (_editJob.id != null && _editJob.stage.isNotEmpty) {
                        initStage = _editJob.stage;
                        // initStage = _initValues['stage'];
                      }
                      print('init stage:$initStage');
                      return DropdownButtonFormField(
                        value: initStage,
                        //     ((stagesData as List<dynamic>).firstWhere((stage) {
                        //   return (stage['priority'] == '0');
                        // }) as dynamic)['id'] as String,
                        validator: _generalValidator,
                        onSaved: (value) {
                          _editJob.stage = value;
                        },
                        onChanged: (value) {
                          _editJob.stage = value;
                        },
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          // filled: false,
                          labelText: 'Stage',
                          // icon: Icon(Icons.menu),
                        ),
                        items: (stagesData as List<dynamic>).map((value) {
                          print('value:$value');
                          print(value['id']);
                          print(value['stage']);
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
                    selectedDate: _editJob.startDate,
                    selectedTime: _editJob.startTime,
                    selectDate: (DateTime date) {
                      setState(() {
                        _editJob.startDate = date;
                      });
                    },
                    selectTime: (TimeOfDay time) {
                      setState(() {
                        _editJob.startTime = time;
                      });
                    },
                  ),
                  DateTimePicker(
                    labelText: 'To',
                    selectedDate: _editJob.endDate,
                    selectedTime: _editJob.endTime,
                    selectDate: (DateTime date) {
                      setState(() {
                        _editJob.endDate = date;
                      });
                    },
                    selectTime: (TimeOfDay time) {
                      setState(() {
                        _editJob.endTime = time;
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
                          value: _editJob.tasks.contains(task['id']),
                          onChanged: (bool value) {
                            setState(() {
                              if (value) {
                                if (!_editJob.tasks.contains(task['id'])) {
                                  _editJob.tasks.add(task['id']);
                                }
                              } else {
                                if (_editJob.tasks.contains(task['id'])) {
                                  _editJob.tasks.remove(task['id']);
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
                    initialValue: _editJob.customerName,
                    validator: _generalValidator,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    initialValue: _editJob.customerEmail,
                    minLines: 1,
                    maxLines: 2,
                    validator: _emailValidator,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Phone',
                    ),
                    initialValue: _editJob.customerPhone,
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
                      var initValue = userData.firstWhere((user) => user['id'] != '0')['id'] as String;
                      if (_editJob.id != null && _editJob.userId.isNotEmpty) {
                        initValue = _editJob.userId;
                      }
                      print('user id: $initValue');
                      return DropdownButtonFormField(
                        value: initValue,
                        // ((userData as List<dynamic>).firstWhere((user) {
                        //   return (user['id'] != '0');
                        // }) as dynamic)['id'] as String,
                        validator: _generalValidator,
                        onSaved: (value) {
                          _editJob.userId = value;
                        },
                        onChanged: (value) {
                          _editJob.userId = value;
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
