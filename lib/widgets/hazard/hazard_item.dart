import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/enums/enum_file.dart';
import 'package:sunrise_job_management/models/hazard.dart';
import 'package:sunrise_job_management/pages/edit_hazard_page.dart';

class HazardItem extends StatefulWidget {
  final DocumentSnapshot hazardSnapshot;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const HazardItem({
    Key key,
    this.hazardSnapshot,
    this.scaffoldKey,
  }) : super(key: key);

  @override
  _HazardItemState createState() => _HazardItemState();
}

class _HazardItemState extends State<HazardItem> {
  Hazard _hazardFromSnapshot;

  @override
  void initState() {
    super.initState();
    _hazardFromSnapshot = Hazard.fromSnapshot(widget.hazardSnapshot);
  }

  void _tryDeleteHazard(CommonOption option) async {
    try {
      bool isActive = false;
      if (option == CommonOption.Active) {
        isActive = true;
      }
      final hazardId = _hazardFromSnapshot.id;
      await Firestore.instance
          .collection('hazards')
          .document(hazardId)
          .updateData({'isActive': isActive}).then((_) => {
                widget.scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    content: Text('Hazard $option successfully.'),
                    backgroundColor: Colors.green,
                    duration: Duration(milliseconds: 2000),
                  ),
                )
              });
      setState(() {
        _hazardFromSnapshot = Hazard.fromSnapshot(widget.hazardSnapshot);
      });
    } catch (err) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text(err.toString()),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
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
          Icons.warning,
          color: _hazardFromSnapshot.isActive ? Colors.green : Colors.red,
        ),
        title: Text(_hazardFromSnapshot.title),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EditHazardPage(_hazardFromSnapshot)));
        },
        trailing: PopupMenuButton<CommonOption>(
          onSelected: (CommonOption result) {
            switch (result) {
              case CommonOption.Modify:
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditHazardPage(_hazardFromSnapshot),
                ));
                break;
              case CommonOption.Active:
                _tryDeleteHazard(CommonOption.Active);
                break;
              case CommonOption.Inactive:
                _tryDeleteHazard(CommonOption.Inactive);
                break;
              default:
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<CommonOption>>[
            const PopupMenuItem<CommonOption>(
              value: CommonOption.Active,
              child: Text('Active'),
            ),
            const PopupMenuItem<CommonOption>(
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
