import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/enums/enum_file.dart';
import 'package:sunrise_job_management/models/user.dart';
import 'package:sunrise_job_management/pages/edit_user_page.dart';

class UserItem extends StatefulWidget {
  final DocumentSnapshot userSnapshot;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const UserItem({
    Key key,
    this.userSnapshot,
    this.scaffoldKey,
  }) : super(key: key);

  @override
  _UserItemState createState() => _UserItemState();
}

class _UserItemState extends State<UserItem> {
  User _userFromSnapshot;

  @override
  void initState() {
    super.initState();
    print('error?');
    _userFromSnapshot = User.fromSnapshot(widget.userSnapshot);
    print(_userFromSnapshot.id);
  }

  void _tryDeleteUser(UserOption option) async {
    try {
      bool isActive = false;
      var actionString = 'Inactive';
      if (option == UserOption.Active) {
        isActive = true;
        actionString = 'Active';
      }
      print('isActive: $isActive');
      final userId = _userFromSnapshot.id;
      print('userId: $userId');
      await Firestore.instance
          .collection('users')
          .document(userId)
          .updateData({'isActive': isActive}).then((value) => {
                widget.scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    content: Text('User $actionString success'),
                    backgroundColor: Colors.green,
                    duration: Duration(milliseconds: 2000),
                  ),
                )
              });
      setState(() {
        _userFromSnapshot = User.fromSnapshot(widget.userSnapshot);
      });
    } catch (err) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text(err.toString()),
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
  }

  @override
  Widget build(BuildContext context) {
    print('aaa');
    print(
        (_userFromSnapshot.avatar == null || _userFromSnapshot.avatar.isEmpty));
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey,
          backgroundImage: (_userFromSnapshot.avatar == null ||
                  _userFromSnapshot.avatar.isEmpty)
              ? AssetImage('images/avatar.jpg')
              : NetworkImage(_userFromSnapshot.avatar),
        ),
        // Icon(
        //   Icons.person,
        //   color: _userFromSnapshot.isActive ? Colors.blue : Colors.red,
        // ),
        title: Text(
            '${_userFromSnapshot.firstName != null ? _userFromSnapshot.firstName : _userFromSnapshot.username} ${_userFromSnapshot.lastName == null ? '' : _userFromSnapshot.lastName}'),
        subtitle: Text(
            '${_userFromSnapshot.username} - ${_userFromSnapshot.phone == null ? 'Phone' : _userFromSnapshot.phone}'),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EditUserPage(_userFromSnapshot)));
        },
        trailing: PopupMenuButton<UserOption>(
          onSelected: (UserOption result) {
            switch (result) {
              case UserOption.Modify:
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => EditUserPage(_userFromSnapshot)));
                break;
              case UserOption.Active:
                _tryDeleteUser(UserOption.Active);
                break;
              case UserOption.Inactive:
                _tryDeleteUser(UserOption.Inactive);
                break;
              default:
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<UserOption>>[
            PopupMenuItem<UserOption>(
              value: UserOption.Modify,
              child: Row(
                children: [
                  Icon(Icons.edit),
                  Text('Edit'),
                ],
              ),
            ),
            if (!_userFromSnapshot.isActive)
              PopupMenuItem<UserOption>(
                value: UserOption.Active,
                child: Row(
                  children: [
                    Icon(Icons.airplanemode_active),
                    Text('Active'),
                  ],
                ),
              ),
            if (_userFromSnapshot.isActive)
              PopupMenuItem<UserOption>(
                value: UserOption.Inactive,
                child: Row(
                  children: [
                    Icon(Icons.airplanemode_inactive),
                    Text('Inactive'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
