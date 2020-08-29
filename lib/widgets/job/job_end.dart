import 'package:flutter/material.dart';
import 'package:sunrise_job_management/models/job.dart';

class JobEnd extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Job jobData;

  JobEnd(this.scaffoldKey, this.jobData);

  @override
  _JobEndState createState() => _JobEndState();
}

class _JobEndState extends State<JobEnd> {
  bool isReportMissPanelExpanded = false;
  bool isReportIncidentPanelExpanded = false;
  bool isUploadPhotoPanelExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPanel(),
          SizedBox(
            height: 15,
          ),
          _buildButtons(),
        ],
      ),
    );
  }

  void _expandPanel(int index, bool isExpanded) {
    setState(() {
      if (index == 0) {
        isReportMissPanelExpanded = !isExpanded;
      } else if (index == 1) {
        isReportIncidentPanelExpanded = !isExpanded;
      } else {
        isUploadPhotoPanelExpanded = !isExpanded;
      }
    });
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: _expandPanel,
      children: [
        _buildReportMissExpansionPanel(),
        _buildReportIncidentExpansionPanel(),
        _buildUploadPhotoExpansionPanel(),
      ],
    );
  }

  /* Report misses start */
  ExpansionPanel _buildReportMissExpansionPanel() {
    return ExpansionPanel(
      headerBuilder: (context, isExpanded) {
        return ListTile(
          title: Text('Report Any Near Misses'),
        );
      },
      canTapOnHeader: true,
      body: Center(
        child: Text('report misses'),
      ),
      isExpanded: isReportMissPanelExpanded,
    );
  }
  /* Report misses end */

  /* Report incident start */
  ExpansionPanel _buildReportIncidentExpansionPanel() {
    return ExpansionPanel(
      headerBuilder: (context, isExpanded) {
        return ListTile(
          title: Text('Report Any Incidents'),
        );
      },
      canTapOnHeader: true,
      body: Center(
        child: Text('report incidents'),
      ),
      isExpanded: isReportIncidentPanelExpanded,
    );
  }
  /* Report incident end */

  /* Upload photo start */
  // TODO: add after photos
  ExpansionPanel _buildUploadPhotoExpansionPanel() {
    return ExpansionPanel(
      headerBuilder: (context, isExpanded) {
        return ListTile(
          title: Text('Upload After Photos'),
        );
      },
      canTapOnHeader: true,
      body: Center(
        child: Text('upload photos'),
      ),
      isExpanded: isUploadPhotoPanelExpanded,
    );
  }
  /* Upload photo end */

  /* Buttons start */
  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          RaisedButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer),
                Text('End Visit'),
              ],
            ),
            onPressed: _endVisitBtnClick,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            color: Colors.amber,
            textColor: Theme.of(context).primaryTextTheme.button.color,
            elevation: 3,
          ),
        ],
      ),
    );
  }

  void _endVisitBtnClick() {
    print('end visit');
    // TODO:
    // 1. save is end
    // 2. save end real date, real time
  }
}
