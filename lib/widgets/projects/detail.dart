import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:worker/widgets/projects/absents_today.dart';
import 'package:worker/widgets/projects/today_clock_in.dart';

import '../global.dart';
import '../widgets.dart';
import 'list_workdays.dart';
import 'list_worwers.dart';

class DetailProject extends StatefulWidget {
  Map<String, dynamic>? project;

  DetailProject({this.project});

  @override
  _DetailProjectState createState() => _DetailProjectState(project);
}

class _DetailProjectState extends State<DetailProject> {
  Map<String, dynamic>? project;
  _DetailProjectState(this.project);
  Map<String, dynamic>? detailProject;
  String? isData = '';

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<dynamic> getDetailProject() async {
    String token = await getToken();
    int project = widget.project!['id'];

    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/contract/business-user/$project'),
        headers: {"Authorization": "Token $token"});

    var resBody = json.decode(utf8.decode(res.bodyBytes));

    setState(() {
      detailProject = resBody;
      if (detailProject!.isNotEmpty) {
        isData = 'Y';
      } else {
        isData = 'N';
      }
    });

    print(resBody);

    return "Sucess";
  }

  @override
  void initState() {
    super.initState();
    getDetailProject();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(left: 5),
                  alignment: Alignment.topLeft,
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: Container(
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: HexColor('EA6012'),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(right: 5),
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: Container(
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: HexColor('EA6012'),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  widget.project != null
                      ? widget.project!['contract_name']
                      : '---',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: HexColor('3E3E3E')),
                ),
              )),
          Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  widget.project != null ? widget.project!['customer'] : '---',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: HexColor('EA6012')),
                ),
              )),
          Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  widget.project != null
                      ? (widget.project!['first_address'] ?? "")
                      : '---',
                  style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              )),
          Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  widget.project!['current_workday_status'] == 'CIS'
                      ? 'Clock-in iniciado'
                      : widget.project!['current_workday_status'] == 'CIE'
                          ? 'Clock-in finalizado'
                          : widget.project!['current_workday_status'] == 'COS'
                              ? 'Clock-out iniciado'
                              : widget.project!['current_workday_status'] ==
                                      'C0E'
                                  ? 'Clock-out finalizado'
                                  : widget.project!['current_workday_status'] ==
                                          'WRE'
                                      ? l10n.complete_report
                                      : 'Por iniciar jornada',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Card(
              margin: EdgeInsets.only(left: 20, right: 20),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: HexColor('EA6012'), width: 1),
                  borderRadius: BorderRadius.circular(10.0)),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Container(
                      alignment: Alignment.topLeft,
                      // margin: EdgeInsets.only(left: 10),
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  l10n.total_assigned,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: HexColor('3E3E3E')),
                                ),
                              )),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 2,
                      child: Container(
                        alignment: Alignment.topRight,
                        // margin: EdgeInsets.only(left: 30),
                        width: MediaQuery.of(context).size.width * 0.20,
                        child: Row(
                          children: <Widget>[
                            Container(
                              //margin: EdgeInsets.only(left: 5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ListWorkersProject(
                                                  contract:
                                                      widget.project!['id'],
                                                  project: widget.project,
                                                )),
                                      );
                                    },
                                    child: Container(
                                        margin: EdgeInsets.only(left: 18),
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: Text(
                                            detailProject != null
                                                ? detailProject![
                                                        'number_of_workers']
                                                    .toString()
                                                : '0',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 50,
                                                color: HexColor('EA6012')),
                                          ),
                                        )),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ))
                ],
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Card(
              margin: EdgeInsets.only(left: 20, right: 20),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: HexColor('EA6012'), width: 1),
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(left: 10, top: 10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Clocked-in',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: HexColor('3E3E3E')),
                        ),
                      )),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.topCenter,
                          //  margin: EdgeInsets.only(left: 10),
                          width: MediaQuery.of(context).size.width * 0.33,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                              Container(
                                  child: Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  detailProject != null
                                      ? detailProject!['clock_ins_average']
                                          .toString()
                                      : '0',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 40,
                                      color: HexColor('EA6012')),
                                ),
                              )),
                              Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      l10n.last7,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: HexColor('3E3E3E')),
                                    ),
                                  )),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.topCenter,
                          //  margin: EdgeInsets.only(left: 10),
                          width: MediaQuery.of(context).size.width * 0.33,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                              Container(
                                  child: Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  detailProject != null
                                      ? detailProject!['yesterday_clock_ins']
                                          .toString()
                                      : '0',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 40,
                                      color: HexColor('EA6012')),
                                ),
                              )),
                              Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      l10n.yesterday,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: HexColor('3E3E3E')),
                                    ),
                                  )),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.topCenter,
                            //margin: EdgeInsets.only(left: 30),
                            width: MediaQuery.of(context).size.width * 0.33,
                            child: Row(
                              children: <Widget>[
                                if (detailProject != null &&
                                    detailProject!['today_clock_ins'] !=
                                        null) ...[
                                  if (detailProject!['today_clock_ins'] >
                                      detailProject![
                                          'yesterday_clock_ins']) ...[
                                    Icon(
                                      Icons.arrow_upward,
                                      color: Colors.green,
                                      size: 40,
                                    )
                                  ],
                                  if (detailProject!['yesterday_clock_ins'] >
                                      detailProject!['today_clock_ins']) ...[
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.red,
                                      size: 40,
                                    )
                                  ],
                                  if (detailProject!['yesterday_clock_ins'] ==
                                      detailProject!['today_clock_ins']) ...[
                                    Icon(
                                      Icons.arrow_upward,
                                      color: Colors.white,
                                      size: 40,
                                    )
                                  ],
                                ],
                                Container(
                                  //  margin: EdgeInsets.only(left: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                          child: Align(
                                        alignment: Alignment.topLeft,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TodayClockIn(
                                                        workday: detailProject !=
                                                                null
                                                            ? detailProject![
                                                                'today_workday']
                                                            : 0,
                                                        contract:
                                                            widget.project,
                                                      )),
                                            );
                                          },
                                          child: Text(
                                            detailProject != null
                                                ? detailProject![
                                                        'today_clock_ins']
                                                    .toString()
                                                : '0',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 40,
                                                color: HexColor('EA6012')),
                                          ),
                                        ),
                                      )),
                                      Container(
                                          child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          l10n.today,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: HexColor('3E3E3E')),
                                        ),
                                      ))
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ))
                    ],
                  )
                ],
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Card(
              margin: EdgeInsets.only(left: 20, right: 20),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: HexColor('EA6012'), width: 1),
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(left: 10, top: 10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          l10n.absents,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: HexColor('3E3E3E')),
                        ),
                      )),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.topCenter,
                          //  margin: EdgeInsets.only(left: 10),
                          width: MediaQuery.of(context).size.width * 0.33,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                              Container(
                                  child: Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  detailProject != null
                                      ? detailProject![
                                              'absents_average_per_week']
                                          .toString()
                                      : '0',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 40,
                                      color: HexColor('EA6012')),
                                ),
                              )),
                              Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      l10n.last7,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: HexColor('3E3E3E')),
                                    ),
                                  )),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.topCenter,
                          //  margin: EdgeInsets.only(left: 10),
                          width: MediaQuery.of(context).size.width * 0.33,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                              Container(
                                  child: Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  detailProject != null
                                      ? detailProject!['yesterday_absents']
                                          .toString()
                                      : '0',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 40,
                                      color: HexColor('EA6012')),
                                ),
                              )),
                              Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      l10n.yesterday,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: HexColor('3E3E3E')),
                                    ),
                                  )),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.topCenter,
                            //margin: EdgeInsets.only(left: 30),
                            width: MediaQuery.of(context).size.width * 0.33,
                            child: Row(
                              children: <Widget>[
                                if (detailProject != null &&
                                    detailProject!['yesterday_absents'] !=
                                        null) ...[
                                  if (detailProject!['yesterday_absents'] !=
                                      detailProject!['today_absents']) ...[
                                    if (detailProject!['today_absents'] >
                                        detailProject![
                                            'yesterday_absents']) ...[
                                      Icon(
                                        Icons.arrow_upward,
                                        color: Colors.red,
                                        size: 40,
                                      )
                                    ],
                                    if (detailProject!['yesterday_absents'] >
                                        detailProject!['today_absents']) ...[
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Colors.green,
                                        size: 40,
                                      )
                                    ],
                                  ],
                                  if (detailProject!['yesterday_absents'] ==
                                      detailProject!['today_absents']) ...[
                                    Icon(
                                      Icons.arrow_upward,
                                      color: Colors.white,
                                      size: 40,
                                    )
                                  ]
                                ],
                                Container(
                                  //  margin: EdgeInsets.only(left: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                          child: Align(
                                        alignment: Alignment.topLeft,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TodayAbsents(
                                                        workday: detailProject![
                                                            'today_workday'],
                                                        contract:
                                                            widget.project,
                                                      )),
                                            );
                                          },
                                          child: Text(
                                            detailProject != null
                                                ? detailProject![
                                                        'today_absents']
                                                    .toString()
                                                : '0',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 40,
                                                color: HexColor('EA6012')),
                                          ),
                                        ),
                                      )),
                                      Container(
                                          child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          l10n.today,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: HexColor('3E3E3E')),
                                        ),
                                      ))
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ))
                    ],
                  )
                ],
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Card(
              margin: EdgeInsets.only(left: 20, right: 20),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: HexColor('EA6012'), width: 1),
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(left: 10, top: 10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          l10n.hours_worked,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: HexColor('3E3E3E')),
                        ),
                      )),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.topCenter,
                          // margin: EdgeInsets.only(left: 10),
                          width: MediaQuery.of(context).size.width * 0.33,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                              Container(
                                  //margin: EdgeInsets.only(left: 10),
                                  child: Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  detailProject != null
                                      ? detailProject!['worked_hours_lw']
                                          .toString()
                                      : '0',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 40,
                                      color: HexColor('EA6012')),
                                ),
                              )),
                              Container(
                                  // margin: EdgeInsets.only(left: 10),
                                  child: Align(
                                alignment: Alignment.topCenter,
                                child: Text(
                                  l10n.last_week,
                                  style: TextStyle(
                                      fontSize: 12, color: HexColor('3E3E3E')),
                                ),
                              )),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.topCenter,
                            //margin: EdgeInsets.only(left: 30),
                            width: MediaQuery.of(context).size.width * 0.33,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  //margin: EdgeInsets.only(left: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                          child: Align(
                                        alignment: Alignment.topCenter,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ListWorkdayReports(
                                                          contract: widget
                                                              .project!['id'])),
                                            );
                                          },
                                          child: Text(
                                            detailProject != null
                                                ? detailProject![
                                                        'worked_hours_cw']
                                                    .toString()
                                                : '0',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 40,
                                                color: HexColor('EA6012')),
                                          ),
                                        ),
                                      )),
                                      Container(
                                          child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Text(
                                          l10n.current_week,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: HexColor('3E3E3E')),
                                        ),
                                      ))
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )),
                      Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.topCenter,
                            //margin: EdgeInsets.only(left: 30),
                            width: MediaQuery.of(context).size.width * 0.33,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  //margin: EdgeInsets.only(left: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                          child: Align(
                                        alignment: Alignment.topCenter,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ListWorkdayReports(
                                                          contract: widget
                                                              .project!['id'])),
                                            );
                                          },
                                          child: Text(
                                            detailProject != null
                                                ? detailProject![
                                                        'worked_hours_yesterday']
                                                    .toString()
                                                : '0',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 40,
                                                color: HexColor('EA6012')),
                                          ),
                                        ),
                                      )),
                                      Container(
                                          child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Text(
                                          l10n.yesterday,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: HexColor('3E3E3E')),
                                        ),
                                      ))
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ))
                    ],
                  )
                ],
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
        ],
      ),
    );
  }
}
