import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/job.dart';

class JobForm extends StatefulWidget {
  @override
  _JobFormState createState() => _JobFormState();
}

class _JobFormState extends State<JobForm> {
  final GlobalKey<FormState> _jobFormKey = GlobalKey<FormState>();
  Job _jobData = Job(
      id: '',
      code: '',
      title: '',
      address: '',
      stage: 'Start',
      serviceDate: '',
      createdAt: '',
      tasks: [],
      customerId: '');
  final _titleInputController = TextEditingController();
  final _addressInputController = TextEditingController();
  final _addressFocusNode = FocusNode();
  final _stageInputController = TextEditingController();
  final _serviceDateInputController = TextEditingController();
  final _startDateTimeInputController = TextEditingController();
  final _endDateTimeInputController = TextEditingController();
  final _tasksInputController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _titleInputController.dispose();
    _addressInputController.dispose();
    _addressFocusNode.dispose();
    _stageInputController.dispose();
    _serviceDateInputController.dispose();
    _startDateTimeInputController.dispose();
    _endDateTimeInputController.dispose();
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
              Text('#84349'),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Property Services Job',
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_addressFocusNode);
                },
                minLines: 1,
                maxLines: 2,
                validator: _generalValidator,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Address'),
                minLines: 1,
                maxLines: 2,
                textInputAction: TextInputAction.next,
                validator: _generalValidator,
              ),
              StreamBuilder(
                  stream: Firestore.instance
                      .collection('stages')
                      // .document(futureSnapshot.data.uid)
                      .snapshots(),
                  builder: (ctx, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final userData = userSnapshot.data.documents;
                    return FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Stage',
                            hintText: 'Please select stage',
                          ),
                          isEmpty: false,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _jobData.stage,
                              isDense: true,
                              onChanged: (value) {
                                setState(() {
                                  _jobData.stage = value;
                                });
                              },
                              items: (userData as List<dynamic>).map((value) {
                                return DropdownMenuItem(
                                  value: value['stage'].toString(),
                                  child: Text(value['stage'].toString()),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
