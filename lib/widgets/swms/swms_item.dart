import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/enums/enum_file.dart';
import 'package:sunrise_job_management/models/swms.dart';
import 'package:sunrise_job_management/pages/edit_swms_page.dart';

class SwmsItem extends StatefulWidget {
  final DocumentSnapshot swmsSnapshot;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const SwmsItem({
    Key key,
    this.swmsSnapshot,
    this.scaffoldKey,
  }) : super(key: key);

  @override
  _SwmsItemState createState() => _SwmsItemState();
}

class _SwmsItemState extends State<SwmsItem> {
  Swms _swmsFromSnapshot;

  @override
  void initState() {
    super.initState();
    _swmsFromSnapshot = Swms.fromSnapshot(widget.swmsSnapshot);
  }

  void _tryDeleteSwms(CommonOption option) async {
    try {
      bool isActive = false;
      var actionString = 'Inactive';
      if (option == CommonOption.Active) {
        isActive = true;
        actionString = 'Active';
      }
      final swmsId = _swmsFromSnapshot.id;
      print('object:$isActive');
      print('swmsId:$swmsId');
      await Firestore.instance
          .collection('swmses')
          .document(swmsId)
          .updateData({'isActive': isActive}).then((_) => {
                widget.scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    content: Text('Swms $actionString success.'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                )
              });
      setState(() {
        _swmsFromSnapshot = Swms.fromSnapshot(widget.swmsSnapshot);
      });
    } catch (e) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.adjust,
          color: _swmsFromSnapshot.isActive ? Colors.green : Colors.red,
        ),
        title: Text(_swmsFromSnapshot.title),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditSwmsPage(_swmsFromSnapshot),
          ));
        },
        trailing: PopupMenuButton<CommonOption>(
          onSelected: (CommonOption result) {
            switch (result) {
              case CommonOption.Modify:
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditSwmsPage(_swmsFromSnapshot),
                ));
                break;
              case CommonOption.Active:
                _tryDeleteSwms(CommonOption.Active);
                break;
              case CommonOption.Inactive:
                _tryDeleteSwms(CommonOption.Inactive);
                break;
              default:
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<CommonOption>>[
            const PopupMenuItem(
              value: CommonOption.Active,
              child: Text('Active'),
            ),
            const PopupMenuItem(
              value: CommonOption.Inactive,
              child: Text('Inactive'),
            ),
            const PopupMenuItem(
              value: CommonOption.Modify,
              child: Text('Modify'),
            ),
          ],
        ),
      ),
    );
  }
}
