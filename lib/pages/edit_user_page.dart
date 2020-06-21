import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/models/user.dart';

class EditUserPage extends StatefulWidget {
  static const routeName = '/edit-user';
  final User userData;

  EditUserPage([this.userData]);

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var _appBarTitle = 'Create user';
  User _editUser = User(
      id: null,
      email: '',
      isActive: true,
      username: '',
      phone: '',
      firstName: '',
      middleName: '',
      lastName: '',
      roles: ['normal']);
  final GlobalKey<FormState> _userFormKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print(widget.userData == null);
    if (widget.userData != null) {
      _appBarTitle = 'Edit user';
      _editUser = widget.userData;
    }
  }

  void _trySubmit() async {
    final isValid = _userFormKey.currentState.validate();
    FocusScope.of(context).unfocus();
    // Add createdAt, createdByUserId, roles
    // Update modifiedAt, modifiedByUserId, check has password or not
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
                    TextFormField(
                      key: ValueKey('email'),
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      initialValue: _editUser.email,
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
                      key: ValueKey('password'),
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value.isEmpty || value.length < 7) {
                          return 'Password must be at least 7 characters long';
                        }
                        return null;
                      },
                      onSaved: (value) => _editUser.password = value,
                    ),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value != _editUser.password) {
                          return 'Password do not match!';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    if (_isLoading)
                      CircularProgressIndicator()
                    else
                      RaisedButton(
                        child: Text('Save'),
                        onPressed: _trySubmit,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0),
                        color: Theme.of(context).primaryColor,
                        textColor:
                            Theme.of(context).primaryTextTheme.button.color,
                        elevation: 8,
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
