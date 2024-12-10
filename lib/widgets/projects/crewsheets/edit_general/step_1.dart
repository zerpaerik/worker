import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/providers/workday.dart';
import 'package:worker/providers/crew.dart';
import 'package:worker/widgets/projects/crewsheets/edit_general/fullimg_red.dart';
import 'package:worker/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../model/user.dart';
import '../../../widgets.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'edit_file.dart';
import 'edit_hours.dart';

class EditCrewReport1 extends StatefulWidget {
  static const routeName = '/new-workday';
  Map<String, dynamic>? project;
  Map<String, dynamic>? report;

  EditCrewReport1({this.project, this.report});

  @override
  _EditCrewReport1State createState() => _EditCrewReport1State(project, report);
}

class _EditCrewReport1State extends State<EditCrewReport1> {
  User? user;
  int? workday;
  Map<String, dynamic>? project;
  Map<String, dynamic>? report;
  _EditCrewReport1State(this.project, this.report);

  // ignore: unused_field
  int _selectedIndex = 4;
  bool yes_offer = false;
  int? selectedRadio;
  int? selectedRadio1;
  int? selectedRadio2;
  int? selectedRadio3;
  int? selectedRadio4;
  int? selectedRadio5;
  int? selectedRadio6;
  int? selectedRadio7;
  int? selectedRadio8;
  int? selectedRadio9;
  int? selectedRadio10;

  DateTime? hourClock; // init workday
  DateTime? hourClock1; // fin workday
  DateTime? hourClock2; // init lunch
  DateTime? hourClock3; // fin lunch
  DateTime? hourClock4; // init standby
  DateTime? hourClock5; // fin standby
  DateTime? hourClock6; // init travel
  DateTime? hourClock7; // fin travel
  DateTime? hourClock8; // init return
  DateTime? hourClock9; // fin return
  String? durationLunch;
  String? durationStandBy;
  String? durationTravel;
  String? durationReturn;
  String? comments;
  var drivers;
  final _form = GlobalKey<FormState>();
  List data = [];

  String? questions;
  var image;
  List imageArray = [];
  bool isLoading = false;
  bool _viewW = false;
  var rows = [];
  List results = [];
  String query = '';
  TextEditingController? tc;
  int _currentStep = 0;
  String? entry;
  String? departure;
  DateTime? start_time; // fin return
  DateTime? end_time; // fin return

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  getContract() async {
    SharedPreferences contract = await SharedPreferences.getInstance();
    //Return String
    int? intValue = contract.getInt('intValue');
    return intValue;
  }

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  setSelectedRadio1(int val) {
    setState(() {
      selectedRadio1 = val;
    });
  }

  setSelectedRadio2(int val) {
    setState(() {
      selectedRadio2 = val;
    });
  }

  setSelectedRadio3(int val) {
    setState(() {
      selectedRadio3 = val;
    });
  }

  setSelectedRadio4(int val) {
    setState(() {
      selectedRadio4 = val;
    });
  }

  setSelectedRadio5(int val) {
    setState(() {
      selectedRadio5 = val;
    });
  }

  setSelectedRadio6(int val) {
    setState(() {
      selectedRadio6 = val;
    });
  }

  setSelectedRadio7(int val) {
    setState(() {
      selectedRadio7 = val;
    });
  }

  setSelectedRadio8(int val) {
    setState(() {
      selectedRadio8 = val;
    });
  }

  setSelectedRadio9(int val) {
    setState(() {
      selectedRadio9 = val;
    });
  }

  setSelectedRadio10(int val) {
    setState(() {
      selectedRadio10 = val;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        titleTextStyle: TextStyle(
            color: HexColor('373737'),
            fontFamily: 'OpenSansRegular',
            fontWeight: FontWeight.bold,
            fontSize: 20),
        actions: <Widget>[
          TextButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _showErrorDialog1(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        titleTextStyle: TextStyle(
            color: HexColor('373737'),
            fontFamily: 'OpenSansRegular',
            fontWeight: FontWeight.bold,
            fontSize: 20),
        actions: <Widget>[
          TextButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
    });
    print('se fue');
    try {
      Provider.of<WorkDay>(context, listen: false)
          .editWorkdayReportEntry(hourClock, hourClock1, widget.report, '', '')
          .then((response) {
        setState(() {
          isLoading = false;
        });
        if (response['status'] == '200') {
          print('updated fino');
          /*  Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EditWorkdayReport2(user: user, report: this.widget.report)),
          );*/
        } else {
          setState(() {
            isLoading = false;
          });
          _showErrorDialog('');
          //_showErrorDialog('Verifique la información');
        }
      });
    } catch (error) {}
    /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePartOblig2()),
          );*/
  }

  @override
  void initState() {
    tc = TextEditingController();
    selectedRadio = 0;
    selectedRadio1 = 0;
    selectedRadio2 = 0;
    selectedRadio3 = 0;
    selectedRadio4 = 0;
    selectedRadio5 = 0;
    selectedRadio6 = 0;
    selectedRadio7 = 0;
    selectedRadio8 = 0;
    selectedRadio9 = 0;
    selectedRadio10 = 0;
    start_time = DateTime.parse(DateTime.now().toString());
    end_time = DateTime.parse(DateTime.now().toString());

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateFormat format = DateFormat("yyyy-MM-dd");
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SingleChildScrollView(
          child: Form(
        key: _form,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(left: 10),
                    alignment: Alignment.topLeft,
                    //height: MediaQuery.of(context).size.width * 0.1,
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
                    margin: EdgeInsets.only(right: 10),
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
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    l10n.crew_detail,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: HexColor('EA6012')),
                  ),
                )),
            Container(
              margin: EdgeInsets.only(left: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                    DateFormat("MMMM d yyyy")
                        .format(DateTime.parse(
                            widget.report!['workday_entry_time']))
                        .toString(),
                    style: TextStyle(
                        fontSize: 15,
                        color: HexColor('EA6012'),
                        fontWeight: FontWeight.bold)),
              ),
            ),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(l10n.hours + ': ',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(widget.report!['worked_hours'].toString(),
                        style: TextStyle(
                            fontSize: 15,
                            color: HexColor('EA6012'),
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text('Supervisor' + ': ',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(widget.report!['supervisor'].toString(),
                        style: TextStyle(
                            fontSize: 15,
                            color: HexColor('EA6012'),
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Container(
                child: Card(
                    margin: EdgeInsets.only(left: 30, right: 30),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: HexColor('EA6012'), width: 1),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(left: 10),
                                width: MediaQuery.of(context).size.width * 0.70,
                                child: Text('Horas de supervisor',
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: HexColor('EA6012'))),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.topRight,
                                margin: EdgeInsets.only(right: 10),
                                width: MediaQuery.of(context).size.width * 0.30,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: HexColor('EA6012'),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditCrewReportH(
                                                type: 0,
                                                project: widget.project,
                                                report: widget.report,
                                              )),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                children: [
                                  Row(children: [
                                    Text('${l10n.wr_4}: '),
                                    Text(widget.report![
                                                'supervisor_entry_time'] !=
                                            null
                                        ? DateFormat("MMMM d yyyy hh:mm")
                                            .format(DateTime.parse(
                                                widget.report![
                                                    'supervisor_entry_time']))
                                            .toString()
                                        : 'S/H')
                                  ]),
                                  Row(
                                    children: [
                                      Text('${l10n.wr_5}: '),
                                      Text(widget.report![
                                                  'supervisor_exit_time'] !=
                                              null
                                          ? DateFormat("MMMM d yyyy hh:mm")
                                              .format(DateTime.parse(
                                                  widget.report![
                                                      'supervisor_exit_time']))
                                              .toString()
                                          : 'S/H')
                                    ],
                                  )
                                ],
                              ),
                            )),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                      ],
                    ))),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
                child: Card(
                    margin: EdgeInsets.only(left: 30, right: 30),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: HexColor('EA6012'), width: 1),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(left: 10),
                                width: MediaQuery.of(context).size.width * 0.70,
                                child: Text('Jornada Laboral',
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: HexColor('EA6012'))),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.topRight,
                                margin: EdgeInsets.only(right: 10),
                                width: MediaQuery.of(context).size.width * 0.30,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: HexColor('EA6012'),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditCrewReportH(
                                                type: 1,
                                                project: widget.project,
                                                report: widget.report,
                                              )),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                children: [
                                  Row(children: [
                                    Text(l10n.wr_4 + ': '),
                                    Text(DateFormat("MMMM d yyyy hh:mm")
                                        .format(DateTime.parse(widget
                                            .report!['workday_entry_time']))
                                        .toString())
                                  ]),
                                  Row(
                                    children: [
                                      Text(l10n.wr_5 + ': '),
                                      Text(DateFormat("MMMM d yyyy hh:mm")
                                          .format(DateTime.parse(widget.report![
                                              'workday_departure_time']))
                                          .toString())
                                    ],
                                  )
                                ],
                              ),
                            )),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                      ],
                    ))),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
                child: Card(
                    margin: EdgeInsets.only(left: 30, right: 30),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: HexColor('EA6012'), width: 1),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(left: 10),
                                width: MediaQuery.of(context).size.width * 0.70,
                                child: Text(l10n.lunch_time,
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: HexColor('EA6012'))),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.topRight,
                                margin: EdgeInsets.only(right: 10),
                                width: MediaQuery.of(context).size.width * 0.30,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: HexColor('EA6012'),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditCrewReportH(
                                                type: 2,
                                                project: widget.project,
                                                report: widget.report,
                                              )),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(widget.report!['lunch_duration']),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                      ],
                    ))),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
                child: Card(
                    margin: EdgeInsets.only(left: 30, right: 30),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: HexColor('EA6012'), width: 1),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(left: 10),
                                width: MediaQuery.of(context).size.width * 0.70,
                                child: Text('Tiempo de Stand by',
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: HexColor('EA6012'))),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.topRight,
                                margin: EdgeInsets.only(right: 10),
                                width: MediaQuery.of(context).size.width * 0.30,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: HexColor('EA6012'),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditCrewReportH(
                                                type: 3,
                                                project: widget.project,
                                                report: widget.report,
                                              )),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(widget.report!['standby_duration']),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                      ],
                    ))),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
                child: Card(
                    margin: EdgeInsets.only(left: 30, right: 30),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: HexColor('EA6012'), width: 1),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(left: 10),
                                width: MediaQuery.of(context).size.width * 0.70,
                                child: Text('Tiempo de Viaje',
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: HexColor('EA6012'))),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.topRight,
                                margin: EdgeInsets.only(right: 10),
                                width: MediaQuery.of(context).size.width * 0.30,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: HexColor('EA6012'),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditCrewReportH(
                                                type: 4,
                                                project: widget.project,
                                                report: widget.report,
                                              )),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(widget.report!['travel_duration']),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                      ],
                    ))),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
                child: Card(
                    margin: EdgeInsets.only(left: 30, right: 30),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: HexColor('EA6012'), width: 1),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(left: 10),
                                width: MediaQuery.of(context).size.width * 0.70,
                                child: Text('Comentarios',
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: HexColor('EA6012'))),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.topRight,
                                margin: EdgeInsets.only(right: 10),
                                width: MediaQuery.of(context).size.width * 0.30,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: HexColor('EA6012'),
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(widget.report!['comments'] != 0
                                          ? widget.report!['comments']
                                              .toString()
                                          : 'S/C'),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                      ],
                    ))),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
                child: Card(
                    margin: EdgeInsets.only(left: 30, right: 30),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: HexColor('EA6012'), width: 1),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(left: 10),
                                width: MediaQuery.of(context).size.width * 0.70,
                                child: Text('Imagen',
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: HexColor('EA6012'))),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.topRight,
                                margin: EdgeInsets.only(right: 10),
                                width: MediaQuery.of(context).size.width * 0.30,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.upload_file,
                                    color: HexColor('EA6012'),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EditCrewFileReport1(
                                                project: widget.project,
                                                report: widget.report,
                                              )),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => FullImgRed(
                                                    url: widget
                                                        .report!['sheet_photo'],
                                                  )),
                                        );
                                      },
                                      child: Text(
                                        widget.report!['sheet_photo'] != null
                                            ? 'Imagen cargada'
                                            : 'Sin Imagen',
                                        style: TextStyle(
                                            color:
                                                widget.report!['sheet_photo'] !=
                                                        null
                                                    ? Colors.green
                                                    : Colors.red,
                                            fontWeight: FontWeight.bold),
                                      ))
                                ],
                              ),
                            )),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                      ],
                    )))
          ],
        ),
      )),
    );
  }

  // ignore: unused_element
}
