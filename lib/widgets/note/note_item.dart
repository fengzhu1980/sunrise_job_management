import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sunrise_job_management/models/job.dart';
import 'package:sunrise_job_management/models/note.dart';
import 'package:sunrise_job_management/models/user.dart';
import 'package:sunrise_job_management/widgets/note/note_bubble.dart';
import 'package:sunrise_job_management/widgets/note/note_new.dart';

class NoteItem extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Job job;
  const NoteItem(this.scaffoldKey, this.job);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.note),
                SizedBox(
                  width: 4,
                ),
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.headline5,
                ),
                // NoteNew(scaffoldKey, relatedId),
              ],
            ),
            StreamBuilder(
              stream: Firestore.instance
                  .collection('notes')
                  .orderBy(
                    'createdAt',
                    descending: true,
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final notesData = snapshot.data.documents;
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 100,
                  ),
                  child: Column(
                    children: <Widget>[
                      if (job.note.isNotEmpty)
                        StreamBuilder(
                          stream: Firestore.instance
                              .collection('users')
                              .document(job.createdBy)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              final userData = snapshot.data;
                              print(userData['id']);
                              final tempUser = User.fromSnapshot(userData);
                              final tempNote = Note(
                                fristName: tempUser.firstName,
                                lastName: tempUser.lastName,
                                note: job.note,
                              );
                              return NoteBubble(tempNote);
                            }
                          },
                        ),
                      ListView.builder(
                        shrinkWrap: true,
                        reverse: true,
                        itemCount: notesData.length,
                        itemBuilder: (ctx, index) => NoteBubble(
                          Note.fromSnapshot(notesData[index]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
