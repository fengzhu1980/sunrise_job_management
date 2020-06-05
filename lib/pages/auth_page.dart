import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sunrise_job_management/enums/enum_file.dart';
import 'package:sunrise_job_management/models/user.dart';
import 'package:sunrise_job_management/widgets/auth/auth_form.dart';

class AuthPage extends StatefulWidget {
  static const routeName = '/';

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitAuthForm(
    String email,
    String password,
    String username,
    AuthMode authMode,
    BuildContext ctx,
  ) async {
    AuthResult authResult;
    User user;

    try {
      setState(() {
        _isLoading = true;
      });
      if (authMode == AuthMode.Login) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Add user
        user = User(
          id: authResult.user.uid,
          createdAt: DateTime.now().toUtc().toString(),
          email: email,
          isActive: true,
          username: username,
          roles: ['normal'],
        );
        
        await Firestore.instance
            .collection('users')
            .document(authResult.user.uid)
            .setData(user.toMap());
      }

      // Save user info locally
      // final prefs = await SharedPreferences.getInstance();
      // final userData = json.encode({
      //   'userId': user.id,
      //   'username': user.username,
      //   'roles': user.roles
      // });
      // prefs.setString('userData', userData);
    } on PlatformException catch (err) {
      var message = 'An error occurred, please check your credentials!';

      if (err.message != null) {
        message = err.message;
      }

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // print(deviceSize);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(9, 132, 227, 1).withOpacity(0.5),
                  Color.fromRGBO(129, 236, 236, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 90.0),
                      // transform: Matrix4.rotationZ(-8 * pi / 180)  ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).primaryColor,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Sunrise',
                        style: TextStyle(
                          color:
                              Theme.of(context).accentTextTheme.headline1.color,
                          fontSize: 50,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: AuthForm(
                      submitFn: _submitAuthForm,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
