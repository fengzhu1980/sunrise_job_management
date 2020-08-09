import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sunrise_job_management/models/job.dart';
import 'package:sunrise_job_management/models/stage.dart';
import 'package:sunrise_job_management/models/task.dart';
import 'package:sunrise_job_management/models/user.dart';
import 'package:sunrise_job_management/pages/job_details_page.dart';

import 'package:sunrise_job_management/widgets/public/app_drawer.dart';
import 'package:sunrise_job_management/widgets/public/top_bar.dart';
import 'package:table_calendar/table_calendar.dart';

class JobsOverviewPage extends StatefulWidget {
  static const routeName = '/jobs_overview';
  final String userId;

  const JobsOverviewPage([this.userId]);

  @override
  _JobsOverviewPageState createState() => _JobsOverviewPageState();
}

class _JobsOverviewPageState extends State<JobsOverviewPage>
    with TickerProviderStateMixin {
  Map<DateTime, List> _events;
  List _selectedEvents;
  AnimationController _animationController;
  CalendarController _calendarController;
  TextEditingController _eventController;
  DateTime _selectedDay;
  User _userData;
  Stream _streamUserData;
  List<Task> _tasks;
  Map<String, String> _stages;

  Stream _getUser() {
    return Firestore.instance
        .collection('users')
        .document(widget.userId)
        .snapshots();
  }

  void _getTasks() async {
    var tempTaskDocuments =
        await Firestore.instance.collection('tasks').getDocuments();
    var tempTasks = tempTaskDocuments.documents;

    tempTasks.forEach((task) {
      var tempTask = Task.fromSnapshot(task);
      _tasks.add(tempTask);
    });
  }

  void _getStages() async {
    var tempStageDocuments =
        await Firestore.instance.collection('stages').getDocuments();
    var tempStages = tempStageDocuments.documents;
    tempStages.forEach((stage) {
      var tempStage = Stage.fromSnapshot(stage);
      _stages[tempStage.id] = tempStage.stage;
    });
  }

  @override
  void initState() {
    super.initState();
    _eventController = TextEditingController();
    _events = {};
    _tasks = List<Task>();
    _stages = {};
    var tempNow = DateTime.now();
    _selectedDay = _getDateTimeDate(tempNow);
    _streamUserData = _getUser();
    _getTasks();
    _getStages();

    // DateTime _tempMonday =
    //     DateTime.now().subtract(Duration(days: DateTime.monday));
    // DateTime _tempSunday =
    //     DateTime.now().subtract(Duration(days: DateTime.sunday));
    // _getEventsByDateTime(_tempMonday, _tempSunday);

    // _events = {
    //   _selectedDay.subtract(Duration(days: 30)): [
    //     'Event A0',
    //     'Event B0',
    //     'Event C0'
    //   ],
    //   _selectedDay.subtract(Duration(days: 4)): [
    //     'Event A5',
    //     'Event B5',
    //     'Event C5'
    //   ],
    //   _selectedDay.subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
    //   _selectedDay: ['Event A7', 'Event B7', 'Event C7', 'Event D7'],
    //   _selectedDay.add(Duration(days: 1)): [
    //     'Event A8',
    //     'Event B8',
    //     'Event C8',
    //     'Event C8',
    //     'Event C8',
    //     'Event C8',
    //     'Event C8',
    //     'Event D8'
    //   ],
    //   _selectedDay.add(Duration(days: 3)):
    //       Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
    //   _selectedDay.add(Duration(days: 7)): [
    //     'Event A10',
    //     'Event B10',
    //     'Event C10'
    //   ],
    // };

    _selectedEvents = _events[_selectedDay] ?? [];
    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _calendarController.dispose();
  }

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedDay = _getDateTimeDate(day);
      // _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
    _getEventsByDateTime(first, last);
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
    _getEventsByDateTime(first, last);
  }

  void _getEventsByDateTime(DateTime first, DateTime last) async {
    var tempJobDocuments = await Firestore.instance
        .collection('jobs')
        .where('userId', isEqualTo: widget.userId)
        .where('startDate', isGreaterThanOrEqualTo: first)
        .where('startDate', isLessThanOrEqualTo: last)
        .getDocuments();

    var tempJobs = tempJobDocuments.documents;
    var tempEvents = Map<DateTime, List>();
    tempJobs.forEach((tempJob) {
      var job = Job.fromSnapshot(tempJob);
      var tempDay = _getDateTimeDate(job.startDate);
      if (tempEvents.containsKey(tempDay)) {
        tempEvents[tempDay].add(job.title);
      } else {
        tempEvents[tempDay] = [job.title];
      }
    });
    setState(() {
      _events = tempEvents;
    });
  }

  DateTime _getDateTimeDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  DateTime _getNextMidnight(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day + 1);
  }

  Future<void> _showJobDialog(Job job) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('#${job.code}: ${job.address}'),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Text(
                        '${job.startTime.format(context)} - ${job.endTime.format(context)}'),
                  ),
                  Row(
                    children: <Widget>[
                      Icon(Icons.list),
                      Text(
                        'Tasks',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30 * job.tasks.length * 1.0,
                    width: 250,
                    child: Column(
                      children: <Widget>[
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: job.tasks.length,
                          itemBuilder: (BuildContext buildContext, i) {
                            final tempTask = _tasks.firstWhere(
                                (element) => element.id == job.tasks[i]);
                            return Container(
                              // width: 100,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Icon(Icons.done),
                                  Flexible(child: Text(tempTask.task))
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  RaisedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.work,
                          color: Colors.white,
                        ),
                        Text(
                          'View Linked Job',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              JobDetailsPage(job, _tasks, _stages)));
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                    elevation: 3,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              )
            ],
          );
        });
  }

  _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: _eventController,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Save'),
            onPressed: () {
              if (_eventController.text.isEmpty) return;
              setState(() {
                if (_events[_calendarController.selectedDay] != null) {
                  _events[_calendarController.selectedDay]
                      .add(_eventController.text);
                } else {
                  _events[_calendarController.selectedDay] = [
                    _eventController.text
                  ];
                }
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        // stream: Firestore.instance
        //     .collection('users')
        //     .document(widget.userId)
        //     .snapshots(),
        stream: _streamUserData,
        builder: (ctx, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          _userData = User.fromSnapshot(userSnapshot.data);
          return Scaffold(
            appBar: TopBar('My Jobs'),
            drawer: AppDrawer(_userData),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Card(
                margin: const EdgeInsets.all(9),
                child: SingleChildScrollView(
                  child: Container(
                    height: 1000,
                    // height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 14.0),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.tag_faces,
                                size: 36,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Flexible(
                                child: Text(
                                  'Good Afternoon Admin',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ColoredBox(
                          color: Theme.of(context).primaryColor,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.work,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '0',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 25,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Jobs Today',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        ColoredBox(
                          color: Colors.green[300],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.skip_next,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '0',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 25,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Jobs Tomorrow',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // _buildTableCalendar(),
                        // const SizedBox(height: 8.0),
                        // _buildButtons(),
                        // const SizedBox(height: 8.0),
                        // _buildEventList(context, userData.id),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              // Switch out 2 lines below to play with TableCalendar's settings
                              //-----------------------
                              // _buildTableCalendar(),
                              _buildTableCalendarWithBuilders(),
                              const SizedBox(height: 8.0),
                              // _buildButtons(),
                              // const SizedBox(height: 8.0),
                              _buildEventList(context, _userData.id),
                              // Expanded(
                              //     child: _buildEventList(
                              //         context, userData.id)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  // // Simple TableCalendar configuration (using Styles)
  // Widget _buildTableCalendar() {
  //   return TableCalendar(
  //     availableGestures: AvailableGestures.horizontalSwipe,
  //     calendarController: _calendarController,
  //     events: _events,
  //     startingDayOfWeek: StartingDayOfWeek.monday,
  //     calendarStyle: CalendarStyle(
  //       selectedColor: Theme.of(context).primaryColor,
  //       todayColor: Colors.deepOrange[200],
  //       markersColor: Colors.brown[700],
  //       outsideDaysVisible: false,
  //     ),
  //     headerStyle: HeaderStyle(
  //       formatButtonTextStyle:
  //           TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
  //       formatButtonDecoration: BoxDecoration(
  //         color: Colors.deepOrange[400],
  //         borderRadius: BorderRadius.circular(16.0),
  //       ),
  //     ),
  //     onDaySelected: _onDaySelected,
  //     onVisibleDaysChanged: _onVisibleDaysChanged,
  //     onCalendarCreated: _onCalendarCreated,
  //   );
  // }

  // More advanced TableCalendar configuration (using Builders & Styles)
  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
        CalendarFormat.week: '',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
        holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
      ),
      headerStyle: HeaderStyle(
        centerHeaderTitle: true,
        formatButtonVisible: false,
      ),
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color: Colors.deepOrange[300],
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            color: Colors.amber[400],
            width: 100,
            height: 100,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }

          if (holidays.isNotEmpty) {
            children.add(
              Positioned(
                right: -2,
                top: -2,
                child: _buildHolidaysMarker(),
              ),
            );
          }

          return children;
        },
      ),
      onDaySelected: (date, events) {
        _onDaySelected(date, events);
        _animationController.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.brown[500]
            : _calendarController.isToday(date)
                ? Colors.brown[300]
                : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  Widget _buildButtons() {
    final dateTime = _events.keys.elementAt(_events.length - 2);

    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              child: Text('Month'),
              onPressed: () {
                setState(() {
                  _calendarController.setCalendarFormat(CalendarFormat.month);
                });
              },
            ),
            RaisedButton(
              child: Text('2 weeks'),
              onPressed: () {
                setState(() {
                  _calendarController
                      .setCalendarFormat(CalendarFormat.twoWeeks);
                });
              },
            ),
            RaisedButton(
              child: Text('Week'),
              onPressed: () {
                setState(() {
                  _calendarController.setCalendarFormat(CalendarFormat.week);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        RaisedButton(
          child: Text(
              'Set day ${dateTime.day}-${dateTime.month}-${dateTime.year}'),
          onPressed: () {
            _calendarController.setSelectedDay(
              DateTime(dateTime.year, dateTime.month, dateTime.day),
              runCallback: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildEventList(BuildContext ctx, String userId) {
    // return ListView(
    //   children: _selectedEvents
    //       .map((event) => Container(
    //             decoration: BoxDecoration(
    //               border: Border.all(width: 0.8),
    //               borderRadius: BorderRadius.circular(12.0),
    //             ),
    //             margin: const EdgeInsets.symmetric(
    //                 horizontal: 8.0, vertical: 4.0),
    //             child: ListTile(
    //               title: Text(event.toString()),
    //               onTap: () => print('$event tapped!'),
    //             ),
    //           ))
    //       .toList(),
    // );
    return StreamBuilder(
      stream: Firestore.instance
          .collection('jobs')
          .where('userId', isEqualTo: userId)
          .where('startDate', isGreaterThanOrEqualTo: _selectedDay)
          .where('startDate', isLessThan: _getNextMidnight(_selectedDay))
          .snapshots(),
      builder: (ctx, jobsSnapshot) {
        if (jobsSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (jobsSnapshot.data.documents.length == 0) {
            return ColoredBox(
              color: Colors.amber,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.tag_faces,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'No jobs',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: jobsSnapshot.data.documents.length,
              itemBuilder: (_, i) {
                Job jobData = Job.fromSnapshot(jobsSnapshot.data.documents[i]);
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.8),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    title: Text(
                        '${DateFormat('dd-MM-yyyy').format(jobData.startDate.toLocal())} - ${jobData.startTime.format(context)}'),
                    subtitle: Text(jobData.title),
                    onTap: () => _showJobDialog(jobData),
                  ),
                );
              },
            );
          }
        }
      },
    );
  }
}
