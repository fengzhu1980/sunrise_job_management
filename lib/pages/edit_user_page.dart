import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sunrise_job_management/models/user.dart';
import 'package:sunrise_job_management/widgets/public/user_avatar_picker.dart';

class EditUserPage extends StatefulWidget {
  static const routeName = '/edit-user';
  final User userData;
  final bool isFromSetting;

  EditUserPage([this.userData, this.isFromSetting = false]);

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var _appBarTitle = 'Create user';
  File _userImageFile;
  User _editUser = User(
      id: null,
      avatar: '',
      email: '',
      isActive: true,
      username: '',
      phone: '',
      firstName: '',
      middleName: '',
      lastName: '',
      roles: ['normal']);
  final GlobalKey<FormState> _userFormKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print(widget.userData == null);
    if (widget.userData != null) {
      if (widget.isFromSetting) {
        _appBarTitle = 'Setting';
      } else {
        _appBarTitle = 'Edit user';
      }
      _editUser = widget.userData;
    }
    print('avatar: ${_editUser.avatar}');
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.clear();
  }

  void _pickedImage(File image) {
    _userImageFile = image;
    print(_userImageFile);
    print(_userImageFile.path);
    print(p.extension(_userImageFile.path));
  }

  void _deleteUserAvatar() {
    _editUser.avatar = null;
  }

  Future<String> _uploadImage(String uid) async {
    String _fileExtension = p.extension(_userImageFile.path);
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_image')
        .child(uid + _fileExtension);
    await ref.putFile(_userImageFile).onComplete;
    return await ref.getDownloadURL();
  }

  static Future<AuthResult> _register(String email, String password) async {
    FirebaseApp app = await FirebaseApp.configure(
      name: 'Secondary',
      options: await FirebaseApp.instance.options,
    );
    return FirebaseAuth.fromApp(app).createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  void _trySubmit() async {
    final isValid = _userFormKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      try {
        setState(() {
          _isLoading = true;
        });

        // TODO
        // Check is email inused
        _userFormKey.currentState.save();
        final _currentUser = await FirebaseAuth.instance.currentUser();

        // Upload image
        // if (_userImageFile != null) {
        //   String _fileExtension = p.extension(_userImageFile.path);
        //   final ref = FirebaseStorage.instance
        //       .ref()
        //       .child('user_image')
        //       // TODO
        //       .child(_currentUser.uid + _fileExtension);
        //   await ref.putFile(_userImageFile).onComplete;
        //   final _url = await ref.getDownloadURL();
        //   _editUser.avatar = _url;
        // }

        // Add user
        var _oprationType = 'Add';
        var _isSuccess = false;
        if (_editUser.id == null) {
          // Add createdAt, createdByUserId, roles
          _editUser.createdAt = DateTime.now().toUtc();
          _editUser.createdByUserId = _currentUser.uid;
          _editUser.isActive = true;

          // Add auth user
          AuthResult _authResult = await _register(_editUser.email, _passwordController.text);
          // AuthResult _authResult =
          //     await FirebaseAuth.instance.createUserWithEmailAndPassword(
          //   email: _editUser.email,
          //   password: _passwordController.text,
          // );

          if (_userImageFile != null) {
            _editUser.avatar = await _uploadImage(_authResult.user.uid);
          }

          DocumentReference userRef = Firestore.instance
              .collection('users')
              .document(_authResult.user.uid);
          _editUser.id = _authResult.user.uid;
          await userRef.setData(_editUser.toMap());
          _isSuccess = true;
          setState(() {
            _isLoading = false;
          });
        } else {
          // Update modifiedAt, modifiedByUserId
          _oprationType = 'Update';
          _editUser.modifiedAt = DateTime.now().toUtc();
          _editUser.modifiedByUserId = _currentUser.uid;

          if (_userImageFile != null) {
            _editUser.avatar = await _uploadImage(_editUser.id);
            // _editUser.avatar = _uploadImage(_currentUser.uid);
          }

          // TODO
          // 1. Get edit user auth info
          // 2. Update user info
          // 3. Check password changed or not
          // 4. Update password

          // TODO
          // Check user email

          await Firestore.instance
              .collection('users')
              .document(_editUser.id)
              .updateData(_editUser.toMap());

          // Check has password or not
          print('passw: ${_passwordController.text}');
          if (_passwordController.text.isNotEmpty) {
            // var _tempResult = await FirebaseAuth.instance.confirmPasswordReset(oobCode, newPassword)
            await _currentUser.updatePassword(_passwordController.text);
          }

          _isSuccess = true;
          setState(() {
            _isLoading = false;
          });
        }
        if (_isSuccess) {
          scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text('$_oprationType successed.'),
              backgroundColor: Colors.green,
              duration: Duration(milliseconds: 1500),
            ),
          );
        }
      } catch (err) {
        String message = 'An error occurred.';
        print('mess: ${err.message}');
        if (err.message != null) {
          message = err.message;
        }
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text(message),
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
        setState(() {
          _isLoading = false;
        });
      }
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
        actions: [
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
              key: _userFormKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 14.0),
                      child: Row(
                        children: [
                          Icon(Icons.person),
                          Text(
                            'User Details',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ],
                      ),
                    ),
                    UserAvatarPicker(
                        _pickedImage, _editUser.avatar, _deleteUserAvatar),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'First Name'),
                      textCapitalization: TextCapitalization.words,
                      initialValue: _editUser.firstName,
                      validator: _generalValidator,
                      onSaved: (value) => _editUser.firstName = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Middle Name'),
                      textCapitalization: TextCapitalization.words,
                      initialValue: _editUser.middleName,
                      onSaved: (value) => _editUser.middleName = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Last Name'),
                      textCapitalization: TextCapitalization.words,
                      initialValue: _editUser.lastName,
                      validator: _generalValidator,
                      onSaved: (value) => _editUser.lastName = value,
                    ),
                    TextFormField(
                      key: ValueKey('email'),
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      initialValue: _editUser.email,
                      readOnly: _editUser.id != null,
                      validator: _emailValidator,
                      onSaved: (value) => _editUser.email = value,
                    ),
                    TextFormField(
                      key: ValueKey('username'),
                      decoration: InputDecoration(labelText: 'Username'),
                      autocorrect: true,
                      textCapitalization: TextCapitalization.words,
                      initialValue: _editUser.username,
                      validator: (value) {
                        if (value.isEmpty || value.length < 3) {
                          return 'Please enter at least 3 characters';
                        }
                        return null;
                      },
                      onSaved: (value) => _editUser.username = value,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.number,
                      initialValue: _editUser.phone,
                      validator: (value) {
                        if (value.isEmpty ||
                            !RegExp(r'^(((\+?64\s*[-\.]?[3-9]|\(?0[3-9]\)?)\s*[-\.]?\d{3}\s*[-\.]?\d{4})|((\+?64\s*[-\.\(]?2\d{1}[-\.\)]?|\(?02\d{1}\)?)\s*[-\.]?\d{3}\s*[-\.]?\d{3,5})|((\+?64\s*[-\.]?[-\.\(]?800[-\.\)]?|[-\.\(]?0800[-\.\)]?)\s*[-\.]?\d{3}\s*[-\.]?(\d{2}|\d{5})))$')
                                .hasMatch(value)) {
                          return 'Phone is required and should be a number';
                        }
                        return null;
                      },
                      onSaved: (value) => _editUser.phone = value,
                    ),
                    if (_editUser.id == null || widget.isFromSetting)
                      TextFormField(
                        key: ValueKey('password'),
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) {
                          if (_editUser.id == null && value.length < 7) {
                            return 'Password must be at least 7 characters long';
                          }
                          return null;
                        },
                      ),
                    if (_editUser.id == null || widget.isFromSetting)
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Password do not match!';
                          }
                          return null;
                        },
                      ),
                    if (!widget.isFromSetting)
                      Padding(
                        padding: EdgeInsets.only(top: 14.0),
                        child: Text(
                          'Roles',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                    if (!widget.isFromSetting)
                      StreamBuilder(
                        stream:
                            Firestore.instance.collection('roles').snapshots(),
                        builder: (ctx, roleSnapshot) {
                          if (!roleSnapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final rolesData = roleSnapshot.data.documents;
                          return Column(
                            children: (rolesData as List<dynamic>).map((role) {
                              return CheckboxListTile(
                                title: Text(role['role']),
                                value: _editUser.roles.contains(role['role']),
                                onChanged: (bool value) {
                                  setState(() {
                                    if (value) {
                                      if (!_editUser.roles
                                          .contains(role['role'])) {
                                        _editUser.roles.add(role['role']);
                                      }
                                    } else {
                                      if (_editUser.roles
                                          .contains(role['role'])) {
                                        _editUser.roles.remove(role['role']);
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
                      height: 20,
                    ),
                    if (_isLoading)
                      Center(child: CircularProgressIndicator())
                    else
                      Center(
                        child: RaisedButton(
                          child: Text('Save'),
                          onPressed: _trySubmit,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 8.0),
                          color: Theme.of(context).primaryColor,
                          textColor:
                              Theme.of(context).primaryTextTheme.button.color,
                          elevation: 8,
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
