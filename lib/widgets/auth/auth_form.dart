import 'package:flutter/material.dart';
import 'package:sunrise_job_management/enums/enum_file.dart';

class AuthForm extends StatefulWidget {
  AuthForm({
    this.submitFn,
    this.isLoading,
  });

  final void Function(
    String email,
    String password,
    String username,
    AuthMode authMode,
    BuildContext ctx,
  ) submitFn;
  final bool isLoading;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.Login;
  bool _showForgotPassword = true;
  String _email = '';
  String _password = '';
  String _username = '';
  final _passwordController = TextEditingController();
  AnimationController _controller;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(
        _email.trim(),
        _password.trim(),
        _username.trim(),
        _authMode,
        context,
      );
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
        _showForgotPassword = true;
      });
      _controller.reverse();
    }
  }

  List<Widget> buildInputs() {
    List<Widget> textFields = [];

    // If were in the sign up state add name
    if (_authMode == AuthMode.Signup) {
      textFields.add(
        TextFormField(
          decoration: InputDecoration(labelText: 'Username'),
          autocorrect: true,
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value.isEmpty || value.length < 3) {
              return 'Please enter at least 3 characters';
            }
            return null;
          },
          onSaved: (value) => _username = value,
        ),
      );
    }

    // Add email & password
    textFields.add(
      TextFormField(
        key: ValueKey('email'),
        decoration: InputDecoration(labelText: 'Email'),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value.isEmpty || !value.contains('@')) {
            return 'Please enter a valid email address.';
          }
          return null;
        },
        onSaved: (value) => _email = value,
      ),
    );
    textFields.add(
      TextFormField(
        key: ValueKey('password'),
        decoration: InputDecoration(labelText: 'Password'),
        obscureText: true,
        controller: _passwordController,
        validator: (value) {
          if (value.isEmpty || value.length < 7) {
            return 'Password must be at least 7 characters long';
          }
          return null;
        },
        onSaved: (value) => _password = value,
      ),
    );

    return textFields;
  }

  TextFormField _setConfirmPasswordTextFormField() {
    return TextFormField(
      enabled: _authMode == AuthMode.Signup,
      decoration: InputDecoration(labelText: 'Confirm Password'),
      obscureText: true,
      validator: _authMode == AuthMode.Signup
          ? (value) {
              if (value != _passwordController.text) {
                return 'Password do not match!';
              }
              return null;
            }
          : null,
    );
  }

  TextFormField _setUsernameTextFormField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Username'),
      autocorrect: true,
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value.isEmpty || value.length < 3) {
          return 'Please enter at least 3 characters';
        }
        return null;
      },
      onSaved: (value) => _username = value,
    );
  }

  Widget _animatedContainerWidget(TextFormField textFormField) {
    return AnimatedContainer(
      constraints: BoxConstraints(
        minHeight: _authMode == AuthMode.Signup ? 60 : 0,
        maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
      ),
      duration: Duration(milliseconds: 300),
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: textFormField,
        ),
      ),
    );
  }

  Widget _forgotPasswordWidget(bool visible) {
    return Visibility(
      child: FlatButton(
        child: Text(
          'Forgot Password?',
        ),
        onPressed: () {
          setState(() {
            _authMode = AuthMode.Reset;
            _showForgotPassword = false;
          });
        },
      ),
      visible: visible,
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        // curve: Curves.easeIn,
        // height: _authMode == AuthMode.Signup ? 380 : 270,
        // constraints:
        //     BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 380 : 270, maxHeight: _authMode == AuthMode.Signup ? 500 : 300),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  key: ValueKey('email'),
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                  onSaved: (value) => _email = value,
                ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    key: ValueKey('username'),
                    decoration: InputDecoration(labelText: 'Username'),
                    autocorrect: true,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value.isEmpty || value.length < 3) {
                        return 'Please enter at least 3 characters';
                      }
                      return null;
                    },
                    onSaved: (value) => _username = value,
                  ),
                if (_authMode != AuthMode.Reset)
                  TextFormField(
                    key: ValueKey('password'),
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value.isEmpty || value.length < 7) {
                        return 'Password must be at least 7 characters long';
                      }
                      return null;
                    },
                    onSaved: (value) => _password = value,
                  ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Password do not match!';
                            }
                            return null;
                          }
                        : null,
                  ),
                SizedBox(
                  height: 20,
                ),
                if (widget.isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN'
                          : _authMode == AuthMode.Signup ? 'SIGN UP'
                            : 'RESET'),
                    onPressed: _trySubmit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                    elevation: 8,
                  ),
                if (_authMode == AuthMode.Reset)
                  FlatButton(
                    child: Text(
                        '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                    onPressed: _switchAuthMode,
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textColor: Theme.of(context).primaryColor,
                  ),
                if (_authMode != AuthMode.Reset)
                  _forgotPasswordWidget(_showForgotPassword),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
