import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/models/hazard.dart';

class EditHazardPage extends StatefulWidget {
  static const routeName = '/edit-hazard';
  final Hazard hazardData;

  EditHazardPage([this.hazardData]);

  @override
  _EditHazardPageState createState() => _EditHazardPageState();
}

class _EditHazardPageState extends State<EditHazardPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _hazardFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  var _appBarTitle = 'Create hazard';
  Hazard _editHazard = Hazard(
    id: null,
    title: '',
    description: '',
    swms: [],
    isActive: true,
  );

  @override
  void initState() {
    super.initState();
    if (widget.hazardData != null) {
      _editHazard = widget.hazardData;
      _appBarTitle = 'Edit hazard';
    }
  }

  void _trySubmit() async {
    print('submit');
    final isValid = _hazardFormKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      setState(() {
        _isLoading = true;
      });

      _hazardFormKey.currentState.save();

      var _operationType = 'Add';
      var _isSuccess = false;
      if (_editHazard.id == null) {
        // Add hazard
        _editHazard.createdAt = DateTime.now().toUtc();
        _editHazard.isActive = true;

        try {
          DocumentReference hazardRef =
              Firestore.instance.collection('hazards').document();
          _editHazard.id = hazardRef.documentID;
          await hazardRef.setData(_editHazard.toMap());
          _isSuccess = true;
        } catch (e) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('An error occurred'),
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
        // Update hazard
        _operationType = 'Update';
        _editHazard.modifiedAt = DateTime.now().toUtc();

        await Firestore.instance
            .collection('hazards')
            .document(_editHazard.id)
            .updateData(_editHazard.toMap());
        _isSuccess = true;

        setState(() {
          _isLoading = false;
        });
      }

      if (_isSuccess) {
        scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text('$_operationType hazard successed.'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 2000),
          ),
        );
      }
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
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Card(
          margin: const EdgeInsets.all(9),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _hazardFormKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 14.0),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.work),
                          Text(
                            'Hazard Details',
                            style: Theme.of(context).textTheme.headline6,
                          )
                        ],
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Title',
                        hintText: 'Hazard Title',
                      ),
                      textCapitalization: TextCapitalization.words,
                      initialValue: _editHazard.title,
                      minLines: 1,
                      maxLines: 2,
                      validator: _generalValidator,
                      onSaved: (value) {
                        _editHazard.title = value;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      minLines: 3,
                      maxLines: 4,
                      initialValue: _editHazard.description,
                      validator: _generalValidator,
                      onSaved: (value) {
                        _editHazard.description = value;
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 14.0),
                      child: Text(
                        'Swms',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    StreamBuilder(
                      stream:
                          Firestore.instance.collection('swmses').snapshots(),
                      builder: (ctx, swmsSnapshot) {
                        if (!swmsSnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final swmsData = swmsSnapshot.data.documents;
                        return Column(
                          children: (swmsData as List<dynamic>).map((swms) {
                            return CheckboxListTile(
                              title: Text(swms['title']),
                              value: _editHazard.swms.contains(swms['id']),
                              onChanged: (bool value) {
                                setState(() {
                                  if (value) {
                                    if (!_editHazard.swms
                                        .contains(swms['id'])) {
                                      _editHazard.swms.add(swms['id']);
                                    }
                                  } else {
                                    if (_editHazard.swms.contains(swms['id'])) {
                                      _editHazard.swms.remove(swms['id']);
                                    }
                                  }
                                });
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    if (_isLoading)
                      Center(
                        child: CircularProgressIndicator(),
                      ),
                    if (!_isLoading)
                      Center(
                        child: RaisedButton(
                          child: Text('Save hazard'),
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
