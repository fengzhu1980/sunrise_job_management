import 'package:flutter/material.dart';
import 'package:sunrise_job_management/models/note.dart';

class NoteBubble extends StatelessWidget {
  final Note noteData;
  const NoteBubble(this.noteData);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(12),
                ),
              ),
              width: 140,
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              margin: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${noteData.fristName} ${noteData.lastName}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).accentTextTheme.bodyText1.color,
                    ),
                  ),
                  Text(
                    noteData.note,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).accentTextTheme.bodyText2.color,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        Positioned(
          top: 0,
          left: 120,
          right: null,
          child: CircleAvatar(
            child: Text(
              '${noteData.fristName.substring(1, 2)} ${noteData.lastName.substring(1, 2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).accentTextTheme.bodyText1.color,
              ),
            ),
          ),
        )
      ],
    );
  }
}
