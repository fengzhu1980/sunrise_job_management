import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sunrise_job_management/models/note.dart';

class NoteBubble extends StatelessWidget {
  final Note noteData;
  const NoteBubble(this.noteData);
  @override
  Widget build(BuildContext context) {
    print('noteData: $noteData');
    print('created: ${noteData.createdAt}');
    print('created: ${noteData.note}');
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Wrap(
                  children: <Widget>[
                    Icon(
                      Icons.person,
                      size: 20,
                    ),
                    Text(
                      '${noteData.fristName} ${noteData.lastName}',
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Text(
                    '${DateFormat('EEE, d MMM yyyy, h:mm a').format(noteData.createdAt)}',
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(0),
                  ),
                ),
                // width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                margin: EdgeInsets.only(right: 5),
                // margin: EdgeInsets.symmetric(
                //   vertical: 16,
                //   horizontal: 8,
                // ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      noteData.note,
                      // style: TextStyle(
                      //   fontWeight: FontWeight.bold,
                      //   color:
                      //       Theme.of(context).accentTextTheme.bodyText1.color,
                      // ),
                    )
                  ],
                ),
              ),
            ),
            CircleAvatar(
              child: Text(
                '${noteData.fristName.substring(1, 2).toUpperCase()}${noteData.lastName.substring(1, 2).toUpperCase()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).accentTextTheme.bodyText1.color,
                ),
              ),
            ),
          ],
        ),
        // Positioned(
        //   top: 0,
        //   left: 120,
        //   right: null,
        //   child: CircleAvatar(
        //     child: Text(
        //       '${noteData.fristName.substring(1, 2)} ${noteData.lastName.substring(1, 2)}',
        //       style: TextStyle(
        //         fontWeight: FontWeight.bold,
        //         color: Theme.of(context).accentTextTheme.bodyText1.color,
        //       ),
        //     ),
        //   ),
        // )
      ],
    );
  }
}
