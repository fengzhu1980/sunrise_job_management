import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/enums/enum_option.dart';
import 'package:sunrise_job_management/models/user.dart';
import 'package:sunrise_job_management/pages/edit_user_page.dart';

class UserItem extends StatefulWidget {
  final DocumentSnapshot userSnapshot;
  final GlobalKey<ScaffoldState> scaffoldKey;

  UserItem(this.userSnapshot, this.scaffoldKey);

  @override
  _UserItemState createState() => _UserItemState();
}

class _UserItemState extends State<UserItem> {
  User _userFromSnapshot;

  @override
  void initState() {
    super.initState();
    _userFromSnapshot = User.fromSnapshot(widget.userSnapshot);
  }

  void _showDeleteDialog() async {
    final userName = _userFromSnapshot.username;
    print('username: $userName');
  }

  void _tryDeleteUser(UserOption option) async {
    try {
      bool isActive = false;
      if (option == UserOption.Active) {
        isActive = true;
      }
      print('isActive: $isActive');
      final userId = _userFromSnapshot.id;
      print('userId: $userId');
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
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.person,
          color: _userFromSnapshot.isActive ? Colors.blue : Colors.red,
        ),
        title: Text(
            '${_userFromSnapshot.firstName != null ? _userFromSnapshot.firstName : _userFromSnapshot.username} ${_userFromSnapshot.lastName == null ? '' : _userFromSnapshot.lastName}'),
        subtitle: Text('${_userFromSnapshot.username} - ${_userFromSnapshot.phone == null ? 'Phone' : _userFromSnapshot.phone}'),
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
              value: UserOption.Modify,
              child: Row(
                children: [
                  Icon(Icons.airplanemode_active),
                  Text('Active'),
                ],
              ),
            ),
            if (_userFromSnapshot.isActive)
            PopupMenuItem<UserOption>(
              value: UserOption.Modify,
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
