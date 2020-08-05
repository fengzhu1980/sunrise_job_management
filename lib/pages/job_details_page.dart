import 'package:flutter/material.dart';
import 'package:sunrise_job_management/models/job.dart';
import 'package:sunrise_job_management/models/task.dart';
import 'package:sunrise_job_management/widgets/job/job_overview.dart';

class JobDetailsPage extends StatefulWidget {
  static const routeName = '/job/details';
  final Job job;
  final List<Task> tasks;
  final Map<String, String> stages;

  const JobDetailsPage(this.job, this.tasks, this.stages);

  @override
  _JobDetailsPageState createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  BottomNavigationBarType _type = BottomNavigationBarType.shifting;

  Widget _widgetOptions(int index) {
    final List<Widget> _widgetOptions = <Widget>[
      JobOverview(scaffoldKey, widget.job, widget.tasks, widget.stages),
      Text(
        'Index 1: Business',
        style: optionStyle,
      ),
      Text(
        'Index 2: School',
        style: optionStyle,
      ),
    ];

    return _widgetOptions[index];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Job #${widget.job.code.toString()} details'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Padding(
          padding: EdgeInsets.only(top: 2),
          child: _widgetOptions(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Overview'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            title: Text('Start'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            title: Text('Quotes'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).accentColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
