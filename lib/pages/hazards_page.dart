import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/pages/edit_hazard_page.dart';
import 'package:sunrise_job_management/widgets/hazard/hazard_item.dart';

class HazardsPage extends StatelessWidget {
  static const routeName = '/hazards';
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Hazard Management'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditHazardPage.routeName);
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('hazards')
            .orderBy('createdAt')
            .snapshots(),
        builder: (ctx, hazardsSnapshot) {
          if (hazardsSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (hazardsSnapshot.data.documents.length == 0) {
              return Center(
                child: Text('No Hazards'),
              );
            } else {
              return ListView.builder(
                itemCount: hazardsSnapshot.data.documents.length,
                itemBuilder: (_, i) => Column(
                  children: <Widget>[
                    HazardItem(
                      key: ValueKey(hazardsSnapshot.data.documents[i]['id']),
                      hazardSnapshot: hazardsSnapshot.data.documents[i],
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
