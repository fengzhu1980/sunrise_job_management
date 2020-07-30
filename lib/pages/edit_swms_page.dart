import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/models/swms.dart';

class EditSwmsPage extends StatefulWidget {
  static const routeName = '/edit-swms';
  final Swms swmsData;

  EditSwmsPage([this.swmsData]);

  @override
  _EditSwmsPageState createState() => _EditSwmsPageState();
}

class _EditSwmsPageState extends State<EditSwmsPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _swmsFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  var _appBarTitle = 'Create swms';
  Swms _editSwms = Swms(
    id: null,
    title: '',
    isActive: true,
  );

  @override
  void initState() {
    super.initState();
    if (widget.swmsData != null) {
      _editSwms = widget.swmsData;
    }
  }

  void _trySubmit() async {
    final isValid = _swmsFormKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      setState(() {
        _isLoading = true;
      });

      _swmsFormKey.currentState.save();

      var _operationType = 'Add';
      var _isSuccess = false;
      if (_editSwms.id == null) {
        // Add swms
        _editSwms.createdAt = DateTime.now().toUtc();
        _editSwms.isActive = true;

        try {
          DocumentReference swmsRef =
              Firestore.instance.collection('swmses').document();
          _editSwms.id = swmsRef.documentID;
          await swmsRef.setData(_editSwms.toMap());
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
        // Update
        _operationType = 'Update';
        await Firestore.instance
            .collection('swmses')
            .document(_editSwms.id)
            .updateData(_editSwms.toMap());
        _isSuccess = true;

        setState(() {
          _isLoading = false;
        });
      }

      if (_isSuccess) {
        scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text('$_operationType swms successed.'),
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
            icon: const Icon(Icons.save),
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
              key: _swmsFormKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 14.0),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.work),
                          Text(
                            'Swms Details',
                            style: Theme.of(context).textTheme.headline6,
                          )
                        ],
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Title',
                        hintText: 'Swms Title',
                      ),
                      textCapitalization: TextCapitalization.words,
                      initialValue: _editSwms.title,
                      minLines: 2,
                      maxLines: 3,
                      validator: _generalValidator,
                      onSaved: (value) {
                        _editSwms.title = value;
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
                          child: const Text('Save swms'),
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
