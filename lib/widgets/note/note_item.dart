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
              ],
            ),
            SizedBox(
              height: 8,
            ),
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
                    final tempUser = User.fromSnapshot(userData);
                    final tempNote = Note(
                      fristName: tempUser.firstName,
                      lastName: tempUser.lastName,
                      note: job.note,
                      createdAt: job.createdAt,
                    );
                    return NoteBubble(tempNote);
                  }
                },
              ),
            StreamBuilder(
              stream: Firestore.instance
                  .collection('notes')
                  .where('relatedId', isEqualTo: job.id)
                  .orderBy(
                    'createdAt',
                    descending: true,
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox(
                    height: 5,
                  );
                  // return Center(
                  //   child: CircularProgressIndicator(),
                  // );
                }
                final notesData = snapshot.data.documents;
                print('notesData: $notesData');
                print('notesData: ${notesData.length}');
                print('job.note: ${job.note}');
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 10,
                  ),
                  child: Column(
                    children: <Widget>[
                      if (notesData.length > 0)
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
            NoteNew(scaffoldKey, job.id),
          ],
        ),
      ),
    );
  }
}
