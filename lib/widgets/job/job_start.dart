import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sunrise_job_management/models/hazard.dart';
import 'package:sunrise_job_management/models/job.dart';
import 'package:sunrise_job_management/widgets/public/photo_picker.dart';

class JobStart extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Job jobData;

  JobStart(this.scaffoldKey, this.jobData);

  @override
  _JobStartState createState() => _JobStartState();
}

class _JobStartState extends State<JobStart> {
  // Hazard
  bool isHazardsPanelExpanded = false;
  Stream _streamHazardData;
  List<dynamic> _selectedHazards = [];
  bool _isHazardLoading = false;
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
  // Upload
  bool isPhotoPanelExpanded = false;
  bool _isUploadLoading = false;
  final GlobalKey<FormState> _uploadFormKey = GlobalKey<FormState>();
  File _exteriorImageFile;
  String _exteriorPhoto = '';
  List<dynamic> _beforePhotos = ['', ''];
  var _beforePhotoFiles = Map<int, File>();

  @override
  void initState() {
    super.initState();
    _streamHazardData = _getHazards();
    _selectedHazards = widget.jobData.hazards;
    _exteriorPhoto = widget.jobData.exteriorPhoto;
    if (widget.jobData.beforePhotos == null) {
      _beforePhotos = ['', ''];
    } else {
      if (widget.jobData.beforePhotos.isNotEmpty) {
        _beforePhotos = widget.jobData.beforePhotos;
      } else {
        _beforePhotos = ['', ''];
      }
    }
    print('beforePhotos: ${widget.jobData.beforePhotos}');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPanel(),
          SizedBox(
            height: 15,
          ),
          _buildButtons(),
        ],
      ),
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

/* Buttons start */
  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          RaisedButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer),
                Text('Start Visit'),
              ],
            ),
            onPressed: _startVisitBtnClick,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            color: Theme.of(context).primaryColor,
            textColor: Theme.of(context).primaryTextTheme.button.color,
            elevation: 3,
          ),
          RaisedButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today),
                Text('Reschedule Visit'),
              ],
            ),
            onPressed: _rescheduleVisitBtnClick,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            color: Colors.amber,
            elevation: 3,
          ),
        ],
      ),
    );
  }

  _startVisitBtnClick() {
    print('start');
    // TODO: check hazards and photos first
  }

  _rescheduleVisitBtnClick() {
    print('reschedule');
  }
/* Buttons end */

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            child: Text(
              'Record all 3 photos required below',
              style: TextStyle(fontSize: 16),
            ),
            padding: EdgeInsets.only(left: 10, bottom: 20),
          ),
          _buildPhotosForm(),
        ],
      ),
      isExpanded: isPhotoPanelExpanded,
    );
  }

  void _pickedExteriorImage(File image, [int index]) {
    _exteriorImageFile = image;
  }

  void _pickedBeforeImage(File image, [int index]) {
    print('index:$index');
    // _beforePhotoFiles[index] = image;
    _beforePhotoFiles[index] = image;
    _beforePhotos[index] = image.path;
  }

  void _deleteExteriorPhoto([int index]) {
    setState(() {
      _exteriorPhoto = null;
      _exteriorImageFile = null;
    });
    print('_exteriorPhoto: $_exteriorPhoto');
  }

  void _deleteBeforePhoto([int index]) {
    print('index: $index');
    setState(() {
      if (index != null) {
        _beforePhotos[index] = '';
        _beforePhotoFiles[index] = null;
      }
    });
    print('photos: $_beforePhotos');
  }

  Future<String> _uploadImage(
      String jobId, String imageType, File imageFile, int imageIndex) async {
    String _fileExtension = p.extension(imageFile.path);
    final ref = FirebaseStorage.instance
        .ref()
        .child(imageType)
        .child(jobId + imageType + imageIndex.toString() + _fileExtension);
    await ref.putFile(imageFile).onComplete;
    return await ref.getDownloadURL();
  }

  void _trySavePhotos() async {
    print('save photo');
    final isValid = _uploadFormKey.currentState.validate();
    print('isValid: $isValid');
    FocusScope.of(context).unfocus();

    if (isValid) {
      setState(() {
        _isUploadLoading = true;
      });
      _uploadFormKey.currentState.save();

      final _currentUser = await FirebaseAuth.instance.currentUser();
      // Save photos
      var _tempUpdateData = {
        'modifiedBy': _currentUser.uid,
        'modifiedAt': DateTime.now().toUtc()
      };
      if (_exteriorImageFile != null) {
        var tempExteriorPhotoUrl = await _uploadImage(
            widget.jobData.id, 'job_exterior_image', _exteriorImageFile, 0);
        _tempUpdateData['exteriorPhoto'] = tempExteriorPhotoUrl;
        print('upload exterior finished------------');
      }
      if (_beforePhotoFiles.length > 0) {
        for (MapEntry<int, File> photoFile in _beforePhotoFiles.entries) {
          var tempUrl = await _uploadImage(widget.jobData.id,
              'job_before_image', photoFile.value, photoFile.key);
          _beforePhotos[photoFile.key] = tempUrl;
        }
        _tempUpdateData['beforePhotos'] = _beforePhotos;
        print('upload before finished---------------');
      }

      try {
        print('update Data: $_tempUpdateData');
        await Firestore.instance
            .collection('jobs')
            .document(widget.jobData.id)
            .updateData(_tempUpdateData)
            .then((_) => {
                  widget.scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text('Photos upload success.'),
                      backgroundColor: Colors.green,
                      duration: Duration(milliseconds: 2000),
                    ),
                  ),
                  setState(() {
                    _isUploadLoading = false;
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
      }
    }
  }

  Widget _buildPhotosForm() {
    return Form(
      key: _uploadFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            _buildExteriorPhotoContainer(),
            _buildBeforePhotoContainers(),
            _buildSaveBtn(),
          ],
        ),
      ),
    );
  }

  Widget _buildBeforePhotoContainers() {
    List<Widget> list = List<Widget>();
    for (var i = 0; i < _beforePhotos.length; i++) {
      list.add(_buildBeforePhotoContainer(i, _beforePhotos[i]));
    }
    return Column(
      children: list,
    );
  }

  Widget _buildExteriorPhotoContainer() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey[300],
          width: 1.0,
          style: BorderStyle.solid,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Icon(Icons.photo_camera),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'Exterior Photo Only',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ],
            ),
          ),
          FormField(
            builder: (field) {
              return Column(
                children: [
                  Container(
                    child: PhotoPicker(_pickedExteriorImage, _exteriorPhoto,
                        _deleteExteriorPhoto),
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
            validator: (value) {
              if (_exteriorPhoto == null) {
                return 'Please select a photo';
              } else if (_exteriorPhoto.isEmpty) {
                return 'Please select a photo';
              } else {
                return null;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBeforePhotoContainer(int index, String beforePhoto) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey[300],
          width: 1.0,
          style: BorderStyle.solid,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Icon(Icons.photo_camera),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'Before Photo Only',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ],
            ),
          ),
          FormField(
            builder: (field) {
              return Column(
                children: [
                  Container(
                    child: PhotoPicker(_pickedBeforeImage, beforePhoto,
                        _deleteBeforePhoto, index),
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
            validator: (value) {
              if (_beforePhotos[index] == null) {
                return 'Please select a photo';
              } else if (_beforePhotos[index] == '') {
                return 'Please select a photo';
              } else {
                return null;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveBtn() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey[300],
          width: 1.0,
          style: BorderStyle.solid,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          if (_isUploadLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          if (!_isUploadLoading)
            RaisedButton(
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save),
                  Text('Save Photos'),
                ],
              ),
              onPressed: _trySavePhotos,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).primaryTextTheme.button.color,
              elevation: 3,
            ),
        ],
      ),
    );
  }
/* Upload part end */
}
