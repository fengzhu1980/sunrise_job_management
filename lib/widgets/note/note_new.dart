import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/models/note.dart';

class NoteNew extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String jobId;
  NoteNew(this.scaffoldKey, this.jobId);

  @override
  _NoteNewState createState() => _NoteNewState();
}

class _NoteNewState extends State<NoteNew> {
  final _controller = new TextEditingController();
  final GlobalKey<FormState> _noteFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Note _editNote = Note(
    id: null,
    relatedId: null,
    note: '',
    createdAt: DateTime.now().toUtc(),
    isDeleted: false,
  );

  void _saveNote() async {
    final isValid = _noteFormKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      _noteFormKey.currentState.save();
      var oprationType = 'Add';
      var isSuccess = false;

      final user = await FirebaseAuth.instance.currentUser();
      final userData =
          await Firestore.instance.collection('users').document(user.uid).get();
      if (_editNote.id == null) {
        // Add note
        _editNote.relatedId = widget.jobId;
        // _editNote.note = _editNote.note;
        _editNote.createdAt = DateTime.now().toUtc();
        _editNote.createdBy = user.uid;
        _editNote.fristName = userData['firstName'];
        _editNote.lastName = userData['lastName'];
        _editNote.isDeleted = false;
        try {
          DocumentReference noteRef =
              Firestore.instance.collection('notes').document();
          _editNote.id = noteRef.documentID;
          await noteRef.setData(_editNote.toMap());

          isSuccess = true;
        } catch (e) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('An error occurred'),
              content: Text(e.toString()),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
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
        // Update note
        oprationType = 'Update';
        if (widget.jobId == null) {
          // Dialog
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('An error occurred!'),
              content: Text('Invalid job'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            ),
          );
        } else {
          _editNote.modifiedAt = DateTime.now().toUtc();

          await Firestore.instance
              .collection('notes')
              .document(_editNote.id)
              .updateData(_editNote.toMap());
          isSuccess = true;

          setState(() {
            _isLoading = false;
          });
        }
      }

      if (isSuccess) {
        widget.scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text('$oprationType note successed.'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 2000),
          ),
        );
      }
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Form(
        key: _noteFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _controller,
              // textAlignVertical: TextAlignVertical.top,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              minLines: 3,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'New Note',
                hintText: 'Please input note...',
              ),
              onChanged: (value) {
                setState(() {
                  _editNote.note = value;
                });
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
                  child: Text('Save Note'),
                  onPressed: _saveNote,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).primaryTextTheme.button.color,
                  elevation: 3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
