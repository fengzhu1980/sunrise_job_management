import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/pages/edit_swms_page.dart';
import 'package:sunrise_job_management/widgets/swms/swms_item.dart';

class SwmsPage extends StatelessWidget {
  static const routeName = '/swms';
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Swms management'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditSwmsPage.routeName);
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('swmses')
            .orderBy('createdAt')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.data.documents.length == 0) {
              return Center(
                child: Text('No Swms'),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (_, i) => Column(
                  children: <Widget>[
                    SwmsItem(
                      key: ValueKey(snapshot.data.documents[i]['id']),
                      swmsSnapshot: snapshot.data.documents[i],
                      scaffoldKey: scaffoldKey,
                    ),
                  ],
                ),
              );
            }
          }
        },
      ),
    );
  }
}
