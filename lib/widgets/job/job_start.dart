import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/models/hazard.dart';
import 'package:sunrise_job_management/models/job.dart';

class JobStart extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Job jobData;

  JobStart(this.scaffoldKey, this.jobData);

  @override
  _JobStartState createState() => _JobStartState();
}

class _JobStartState extends State<JobStart> {
  bool isHazardsPanelExpanded = false;
  bool isPhotoPanelExpanded = false;
  Stream _streamHazardData;
  List<dynamic> _selectedHazards = [];
  bool _isHazardLoading = false;
  bool _isUploadLoading = false;
  bool _isSaveHazardLoading = false;
  final GlobalKey<FormState> _hazardFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _addHazardFormKey = GlobalKey<FormState>();
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
    _streamHazardData = _getHazards();
    _selectedHazards = widget.jobData.hazards;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _buildPanel(),
    );
  }

  Stream<QuerySnapshot> _getHazards() {
    return Firestore.instance.collection('hazards').snapshots();
  }

  void _expandPanel(int index, bool isExpanded) {
    setState(() {
      if (index == 0) {
        isHazardsPanelExpanded = !isExpanded;
      } else {
        isPhotoPanelExpanded = !isExpanded;
      }
    });
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: _expandPanel,
      children: [
        _buildHazardsExpansionPanel(),
        _buildUploadPhotoExpansionPanel(),
      ],
    );
  }

/* Hazard part start */
  ExpansionPanel _buildHazardsExpansionPanel() {
    return ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(
          title: Text('Select all the hazards identified at the job.'),
        );
      },
      canTapOnHeader: true,
      body: Form(
        key: _hazardFormKey,
        child: Column(
          children: [
            FormField(
              builder: (field) {
                return StreamBuilder(
                  stream: _streamHazardData,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Text('No Hazards data'),
                      );
                    }
                    final hazardsData = snapshot.data.documents;
                    print('hazards: $hazardsData');
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children:
                              (hazardsData as List<dynamic>).map((hazard) {
                            final tempHazard = Hazard.fromSnapshot(hazard);
                            return CheckboxListTile(
                              title: Text(tempHazard.description),
                              value: _selectedHazards.contains(tempHazard.id),
                              onChanged: (bool value) {
                                setState(() {
                                  if (value) {
                                    if (!_selectedHazards
                                        .contains(tempHazard.id)) {
                                      _selectedHazards.add(tempHazard.id);
                                    }
                                  } else {
                                    if (_selectedHazards
                                        .contains(tempHazard.id)) {
                                      _selectedHazards.remove(tempHazard.id);
                                    }
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            field.errorText ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).errorColor,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              validator: (value) {
                if (_selectedHazards.length == 0) {
                  return 'Please select task';
                } else {
                  return null;
                }
              },
            ),
            if (_isHazardLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
            if (!_isHazardLoading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RaisedButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save),
                          Text('Save Hazards'),
                        ],
                      ),
                      onPressed: _trySaveHazards,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: Theme.of(context).primaryColor,
                      textColor:
                          Theme.of(context).primaryTextTheme.button.color,
                      elevation: 3,
                    ),
                    RaisedButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add),
                          Text('Add Custom Hazard'),
                        ],
                      ),
                      onPressed: _showAddHazardDialog,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: Colors.grey[700],
                      textColor:
                          Theme.of(context).primaryTextTheme.button.color,
                      elevation: 3,
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
      isExpanded: isHazardsPanelExpanded,
    );
  }

  void _trySaveHazards() async {
    // Add hazards into job table
    final isValid = _hazardFormKey.currentState.validate();
    FocusScope.of(context).unfocus();
    print('isValid: $isValid');

    if (isValid) {
      setState(() {
        _isHazardLoading = true;
      });
      _hazardFormKey.currentState.save();

      try {
        await Firestore.instance
            .collection('jobs')
            .document(widget.jobData.id)
            .updateData({'hazards': _selectedHazards}).then((_) => {
                  widget.scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text('Hazards add successfully.'),
                      backgroundColor: Colors.green,
                      duration: Duration(milliseconds: 2000),
                    ),
                  ),
                  setState(() {
                    _isHazardLoading = false;
                  }),
                });
      } catch (e) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('An error occurred'),
            content: Text(e.toString()),
            actions: [
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
        setState(() {
          _isHazardLoading = false;
        });
      }
    }
  }

  // TODO
  void _trySaveNewHazard() async {
    print('save new');
  }

  Future<void> _showAddHazardDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.add_circle),
              Text('Add Hazard'),
            ],
          ),
          content: _buildAddHazardWidget(),
          actions: [
            if (_isSaveHazardLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
            if (!_isSaveHazardLoading)
              RaisedButton(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save),
                    Text('Save'),
                  ],
                ),
                onPressed: _trySaveNewHazard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                color: Theme.of(context).primaryColor,
                textColor: Theme.of(context).primaryTextTheme.button.color,
                elevation: 3,
              ),
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildAddHazardWidget() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        // padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _addHazardFormKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                  stream: Firestore.instance.collection('swmses').snapshots(),
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
                                if (!_editHazard.swms.contains(swms['id'])) {
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _generalValidator(String value) {
    if (value.isEmpty) {
      return 'Please provide a value';
    } else {
      return null;
    }
  }
/* Hazard part end */

/* Upload part start */
  ExpansionPanel _buildUploadPhotoExpansionPanel() {
    return ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(
          title: Text('Upload Before Photos'),
        );
      },
      canTapOnHeader: true,
      body: ListTile(
        title: Text('Upload'),
        subtitle: Text('Details goes here'),
      ),
      isExpanded: isPhotoPanelExpanded,
    );
  }
/* Upload part end */
}
