import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/model/certification.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:worker/providers/workday.dart';
import 'package:worker/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';

import '../../model/user.dart';
import '../../model/workday_register.dart';
import '../global.dart';
import 'base.dart';
import 'edit_ind/workday.dart';
import 'editm/workday.dart';

class DetailWorkDay extends StatefulWidget {
  static const routeName = '/detail-workday';
  final User? user;
  final int? workday;
  Map<String, dynamic>? report;
  Map<String, dynamic>? contract;

  DetailWorkDay(
      {required this.user, required this.workday, this.report, this.contract});

  @override
  _DetailWorkDayState createState() =>
      _DetailWorkDayState(user, workday, report, contract);
}

class _DetailWorkDayState extends State<DetailWorkDay> {
  User? user;
  int? workday;
  Map<String, dynamic>? report;
  Map<String, dynamic>? contract;

  _DetailWorkDayState(this.user, this.workday, this.report, this.contract);
  // ignore: unused_field
  int? _selectedIndex = 3;
  bool loading = false;
  String? verified;
  final String url1 =
      '${ApiWebServer.server_name}/api/v-1/workday/81/workday-report/worker-report/extemporaneus';
  List data = [];
  List data1 = [];
  List datasj = [];
  List datar = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String? isData = '';
  String? isDataSJ = '';
  String? isDataR = '';

  Certification? crt;
  bool? _isData = false;
  bool? isData1 = false;
  List? _selectWorkers = [];
  List? _selectWorkersInfo = [];

  int? selectedRadio;

  //List data = List();
  Map<String, dynamic>? dataw;
  Map<String, dynamic>? reporta;

  bool _isEdit = false;
  bool _selectw = false;
  bool _isSending = false;
  bool _isFin = false;

  bool _onSend = false;
  // FOR EDIT DATA

  var drivers;
  final _form = GlobalKey<FormState>();
  AnimationController? animationController;
  Animation? degOneTranslationAnimation,
      degTwoTranslationAnimation,
      degThreeTranslationAnimation;
  Animation? rotationAnimation;

  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  // ignore: unused_field

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  String? dat;

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  void _showScaffold(String message) {}

  Future<String> getSWData() async {
    String token = await getToken();
    int workday = widget.report!['workday'];
    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/workday/$workday/workday-report/worker-report/on-time'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(utf8.decode(res.bodyBytes));

    if (res.statusCode == 200) {
      setState(() {
        _isData = true;
      });
      if (resBody.length == 0) {
        print('no hay data');
        setState(() {
          isData = 'N';
        });
      } else {
        print('hay data');
        setState(() {
          isData = 'Y';
          data = resBody;
        });
      }
    } else {
      // print(res.statusCode);
    }

    return "Sucess";
  }

  Future<String> getSWData1() async {
    String token = await getToken();
    int? workday = widget.workday;
    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/workday/$workday/workday-report/worker-report/extemporaneus'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(utf8.decode(res.bodyBytes));
    print('por revisar');
    print(resBody);

    /**
     * dataf = data
          .where((data) =>
              data['data']['identifier'] != 'MESSAGE_CHAT' &&
              data['data']['identifier'] != 'CUSTOM_PUSH_NOTIFICATION')
          .toList();
     * 
     */

    if (res.statusCode == 200) {
      setState(() {
        _isData = true;
      });
      if (resBody.length == 0) {
        print('no hay data');
        setState(() {
          isData = 'N';
        });
      } else {
        print('hay data');
        setState(() {
          isData = 'Y';
          data1 =
              resBody.where((resBody) => resBody['editor'] == null).toList();

          datar =
              resBody.where((resBody) => resBody['editor'] != null).toList();
        });
      }
    } else {}

    return "Sucess";
  }

  Future<dynamic> getSWDataSJ() async {
    int wk = widget.report!['id'];
    String token = await getToken();
    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/workday/workday-report/$wk/worker-report/'),
        headers: {"Authorization": "Token $token"});

    var resBody = json.decode(utf8.decode(res.bodyBytes));

    if (res.statusCode == 200) {
      setState(() {
        datasj = resBody
            .where((resBody) =>
                resBody['standby_duration'].toString() != '00:00:00')
            .toList();
        if (datasj.isNotEmpty) {
          isDataSJ = 'Y';
        } else {
          isDataSJ = 'N';
        }
      });
    }

    return datasj;
  }

  Future<String> getReport() async {
    String token = await getToken();
    int re = widget.report!['id'];
    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/workday/workday-report/$re'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);

    if (res.statusCode == 200) {
      setState(() {
        reporta = resBody;
      });
    } else {
      // print(res.statusCode);
    }

    return "Sucess";
  }

  void _onWorkerSelected(
      bool selected, worker_id, worker_name, worker_lastname, worker_btnid) {
    if (selected == true) {
      setState(() {
        _selectWorkers!.add(worker_id);
        _selectWorkersInfo!
            .add(worker_name + ' ' + worker_lastname + ' ' + worker_btnid);
        print(_selectWorkers);
        print(_selectWorkersInfo);
      });
    } else {
      setState(() {
        _selectWorkers!.remove(worker_id);
        _selectWorkersInfo!
            .remove(worker_name + ' ' + worker_lastname + ' ' + worker_btnid);
        print(_selectWorkers);
        print(_selectWorkersInfo);
      });
    }
  }

  void _editInfoUnit(data) {
    WorkdayRegister wk_r = WorkdayRegister.fromJson(data);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Container(
            height: 340,
            child: Column(
              children: <Widget>[
                Container(
                  child: Image.asset(
                    'assets/edit_workday.png',
                    width: 100,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20, top: 40),
                  child: Text(
                    l10n.edit_field_form,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.topCenter,
                          width: MediaQuery.of(context).size.width * 0.50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: Text(
                              l10n.cancel,
                              style: TextStyle(
                                  fontSize: 15, color: HexColor('EA6012')),
                            ),
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.topCenter,
                          width: MediaQuery.of(context).size.width * 0.50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditWorkdayInd1(
                                          user: user,
                                          workday: widget.workday,
                                          wr: wk_r,
                                          report: widget.report,
                                          contract: widget.contract,
                                        )),
                              );
                            },
                            child: Text(
                              l10n.accept,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white),
                            ),
                          ),
                        ))
                  ],
                ),
              ],
            )),
        titleTextStyle: TextStyle(
            color: HexColor('373737'),
            fontFamily: 'OpenSansRegular',
            fontWeight: FontWeight.bold,
            fontSize: 20),
      ),
    );
  }

  void _editInfoMasivo() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Container(
            height: 340,
            child: Column(
              children: <Widget>[
                Container(
                  child: Image.asset(
                    'assets/check.png',
                    width: 140,
                    height: 160,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20, top: 30),
                  child: Text(
                    l10n.w_massive,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: HexColor('233062'), fontSize: 18),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: TextButton(
                    child: Text(
                      l10n.accept,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      /*Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditWorkdayMReport(
                                  user: user,
                                  workday: this.widget.workday,
                                  wr: reporta,
                                )),
                      );*/
                    },
                  ),
                )
              ],
            )),
        titleTextStyle: TextStyle(
            color: HexColor('373737'),
            fontFamily: 'OpenSansRegular',
            fontWeight: FontWeight.bold,
            fontSize: 20),
      ),
    );
  }

  void _showInfoWorker(data) {
    print('data individual report');
    print(data);
    WorkdayRegister wk_r = WorkdayRegister.fromJson(data);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Container(
            height: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      //  margin: EdgeInsets.only(left: 15, right: 80, top: 15),
                      child: Text(
                        'ID: ${wk_r.btn_id}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: HexColor('EA6012'),
                            fontSize: 17),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 20),
                        child: data['is_supervisor'] == true
                            ? Image.asset(
                                'assets/supervisor.png',
                                width: 30,
                              )
                            : data['was_lead'] == true
                                ? Image.asset(
                                    'assets/lead.png',
                                    width: 30,
                                  )
                                : data['was_driver'] == true
                                    ? Image.asset(
                                        'assets/driver.png',
                                        width: 30,
                                      )
                                    : Image.asset(
                                        'assets/worker.png',
                                        width: 30,
                                      )),
                  ],
                ),
                Divider(
                  color: Colors.grey[200],
                  // height: 1,
                  thickness: 2,
                  indent: 15,
                  endIndent: 15,
                ),
                Container(
                    //margin: EdgeInsets.only(left: 15),
                    child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.topLeft,
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: const Text(
                          'Nombre Y Apellido:',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.topLeft,
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: Text(
                          '${wk_r.first_name} ${wk_r.last_name}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                )),
                Divider(
                  color: Colors.grey[200],
                  // height: 1,
                  thickness: 1,
                  indent: 15,
                  endIndent: 15,
                ),

                Row(children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      //color: HexColor('009444'),
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Column(
                        children: <Widget>[
                          Image.asset('assets/001-clock.png', width: 30),
                          SizedBox(
                            height: 5,
                          ),
                          const Text(
                            'Clock-in',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text('${wk_r.clock_in.toString().substring(11, 16)}'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      height: 50,
                      child: VerticalDivider(color: Colors.grey[400])),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Column(
                        children: <Widget>[
                          Image.asset(
                            'assets/002-clock-1.png',
                            width: 30,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          const Text('Clock-out',
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                          Text(
                              '${wk_r.clock_out.toString().substring(11, 16)}'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      height: 50,
                      child: VerticalDivider(color: Colors.grey[400])),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Column(
                        children: <Widget>[
                          Image.asset('assets/entrada.png', width: 30),
                          SizedBox(
                            height: 5,
                          ),
                          Text(l10n.wr_4,
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                          Text(data['workday_entry_time']
                              .toString()
                              .substring(11, 16)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      height: 50,
                      child: VerticalDivider(color: Colors.grey[400])),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Column(
                        children: <Widget>[
                          Image.asset('assets/salida.png', width: 30),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            l10n.wr_5,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(data['workday_departure_time']
                              .toString()
                              .substring(11, 16)),
                        ],
                      ),
                    ),
                  )
                ]),
                Divider(
                  color: Colors.grey[200],
                  // height: 1,
                  thickness: 1,
                  indent: 15,
                  endIndent: 15,
                ),

                SizedBox(height: 10),
                Row(children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      //color: HexColor('009444'),
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Column(
                        children: <Widget>[
                          Image.asset('assets/horast.png', width: 30),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            l10n.wr_20,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text('${data['display_worked_hours']}'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      height: 50,
                      child: VerticalDivider(color: Colors.grey[400])),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Column(
                        children: <Widget>[
                          Image.asset('assets/lunch.png', width: 30),
                          SizedBox(
                            height: 5,
                          ),
                          Text('Almuerzo',
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                          Text(
                              '${wk_r.lunch_duration.toString().substring(0, 5)}'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      height: 50,
                      child: VerticalDivider(color: Colors.grey[400])),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Column(
                        children: <Widget>[
                          Image.asset(
                            'assets/stand.png',
                            width: 30,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text('Stand By',
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                          Text(
                              '${wk_r.standby_duration.toString().substring(0, 5)}'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      height: 50,
                      child: VerticalDivider(color: Colors.grey[400])),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Column(
                        children: <Widget>[
                          Image.asset('assets/duracion.png', width: 30),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Viaje',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                              '${wk_r.travel_duration.toString().substring(0, 5)}'),
                        ],
                      ),
                    ),
                  )
                ]),

                //  SizedBox(height: 5)
              ],
            )),
        titleTextStyle: TextStyle(
            color: HexColor('373737'),
            fontFamily: 'OpenSansRegular',
            fontWeight: FontWeight.bold,
            fontSize: 20),
      ),
    );
  }

  void _showviewRequest(title) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        backgroundColor: Colors.white,
        title: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/aceptar-1.png',
                width: 80,
                color: HexColor('EA6012'),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                alignment: Alignment.center,
                child: Text(title))
          ],
        ),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: HexColor('EA6012'),
          fontSize: 17,
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Ok',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: HexColor('EA6012'),
                  fontSize: 17,
                )),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showviewRequest1() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        backgroundColor: Colors.white,
        title: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/alert.png',
                width: 80,
                color: HexColor('EA6012'),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                alignment: Alignment.center,
                child: Text(l10n.wr_25))
          ],
        ),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: HexColor('EA6012'),
          fontSize: 17,
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Ok',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: HexColor('EA6012'),
                  fontSize: 17,
                )),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<dynamic> _sendReport() async {
    int re = widget.report!['id'];

    setState(() {
      _isSending = true;
    });
    print('se fue');
    try {
      Provider.of<WorkDay>(context, listen: false)
          .sendReport(
        re,
      )
          .then((response) {
        setState(() {});
        if (response == 200) {
          _showviewRequest('¡El Reporte ha sido enviado con Exito!');
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WorkDayPage(
                      user: user,
                      contract: widget.contract,
                      workday: widget.report!['workday'],
                    )),
          );

          setState(() {
            _isSending = false;
            _onSend = true;
          });
        } else {
          setState(() {
            _isSending = false;
            _onSend = true;
          });
        }
      });
    } catch (error) {}
  }

  Future<dynamic> _finWorkday() async {
    final l10n = AppLocalizations.of(context)!;

    int? re = widget.workday;

    print(re);

    setState(() {
      _isFin = true;
    });
    print(_isFin);
    print('se fue finnnn');
    try {
      Provider.of<WorkDay>(context, listen: false)
          .finWorkday(
        re,
      )
          .then((response) {
        setState(() {});
        if (response == '200') {
          _showviewRequest(l10n.wr_38);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WorkDayPage(
                      user: user,
                      contract: widget.contract,
                      workday: widget.report!['workday'],
                    )),
          );

          setState(() {
            _isFin = false;
          });
        } else {
          setState(() {
            _isFin = false;
            _onSend = true;
          });
        }
      });
    } catch (error) {}
    /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePartOblig2()),
          );*/
  }

  void _showPrev() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        backgroundColor: Colors.white,
        title: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/alert.png',
                width: 80,
                color: HexColor('EA6012'),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                alignment: Alignment.center,
                child: Text('¡Aún se esta procesando el envío del Reporte!'))
          ],
        ),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: HexColor('EA6012'),
          fontSize: 17,
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Ok',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: HexColor('EA6012'),
                  fontSize: 17,
                )),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    getSWData();
    getSWData1();
    getSWDataSJ();
    getReport();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    print('aqui');
    print(widget.report);
    print(widget.workday);

    if (widget.report!['had_workday'] == true) {
      return DefaultTabController(
        length: 3,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            elevation: 2.0,
            backgroundColor: Colors.white,
            centerTitle: true,
            iconTheme: IconThemeData(
              color: HexColor('EA6012'),
            ),
            title: Image.asset(
              "assets/homelogo.png",
              width: 120,
              alignment: Alignment.topLeft,
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WorkDayPage(
                            user: user,
                            workday: widget.workday,
                            contract: widget.contract,
                          )),
                );
              },
            ),
          ),
          body: Column(
            // Column
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Row(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(left: 15, top: 10),
                      child: Image.asset('assets/002-data.png',
                          width: 50, color: HexColor('EA6012'))),
                  Container(
                    margin: EdgeInsets.only(left: 10, top: 25),
                    child: Text(l10n.wr_32,
                        style: TextStyle(
                            fontSize: 18,
                            color: HexColor('EA6012'),
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(l10n.date,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          )),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                          widget.report!['created'].toString() != 'null'
                              ? /*'${data['clock_in_start'].toString().substring(0, 10)}'*/ DateFormat(
                                      "MMMM d yyyy")
                                  .format(
                                      DateTime.parse(widget.report!['created']))
                              : 'S/J',
                          style: TextStyle(
                            color: HexColor('EA6012'),
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          )),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('${l10n.hours_worked}:',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          )),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                          widget.report!['worked_hours'].toString() == 'None' ||
                                  widget.report!['worked_hours'].toString() ==
                                      '0:00:00'
                              ? 'S/H'
                              : widget.report!['worked_hours']
                                          .toString()
                                          .length >
                                      3
                                  ? widget.report!['worked_hours'].toString()
                                  : widget.report!['worked_hours'].toString(),
                          style: TextStyle(
                            color: HexColor('EA6012'),
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          )),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(l10n.wr_33 + ':',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          )),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('${data.length}',
                          style: TextStyle(
                            color: HexColor('EA6012'),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          )),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('${l10n.wr_34}:',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          )),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('${data1.length}',
                          style: TextStyle(
                            color: HexColor('EA6012'),
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          )),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('${l10n.wr_35}:',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          )),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('${datar.length}',
                          style: TextStyle(
                            color: HexColor('EA6012'),
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          )),
                    ),
                  ),
                ],
              ),
              if (_isSending) ...[
                Container(
                  //margin: EdgeInsets.only(left: 5),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text('Enviando Reporte...',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        )),
                  ),
                )
              ],
              if (_isFin) ...[
                Container(
                  //margin: EdgeInsets.only(left: 5),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text('Finalizando Jornada...',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        )),
                  ),
                )
              ],
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Container(
                color: Colors.white, // Tab Bar color change
                child: TabBar(
                  // TabBar
                  unselectedLabelColor: Colors.grey,
                  labelColor: Colors.black,
                  indicatorWeight: 3,
                  indicatorColor: HexColor('EA6012'),
                  labelStyle:
                      TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  tabs: [
                    Container(
                      child: Tab(
                        text: l10n.wr_33,
                      ),
                    ),
                    Tab(
                      text: l10n.wr_34,
                    ),
                    Tab(text: l10n.wr_35),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: TabBarView(
                  // Tab Bar View
                  physics: BouncingScrollPhysics(),
                  children: <Widget>[
                    // ignore: unrelated_type_equality_checks
                    isData == ''
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : _getListOnTime(),
                    // ignore: unrelated_type_equality_checks
                    isData1 == ''
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : _getListExt(),
                    isData1 == ''
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : _getListReview()
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: PopupMenuButton(
            // color: HexColor('EA6012'),
            icon: Icon(
              Icons.menu,
              color: HexColor('EA6012'),
            ),
            onSelected: (value) {
              print('value');
              if (value == "edit") {
                if (_selectWorkers!.isEmpty) {
                  _editInfoMasivo();
                } else {
                  setState(() {
                    _isEdit = true;
                  });

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditWorkdayM1(
                              user: user,
                              workday: widget.workday,
                              contract: contract,
                              report: reporta,
                              worker: _selectWorkers,
                              workerDescription: _selectWorkersInfo,
                            )),
                  );
                }
                print(value);
              } else if (value == "fin") {
                if (data1.isEmpty) {
                  _finWorkday();
                } else {
                  _showviewRequest1();
                }
                print(value);
              } else {
                if (data1.isEmpty) {
                  _sendReport();
                } else {
                  _showviewRequest1();
                }
                print(value);
              }
              // your logic
            },
            itemBuilder: (BuildContext bc) {
              return [
                if (data1.isNotEmpty) ...[
                  const PopupMenuItem(
                    child: Text("Editar Multiple"),
                    value: 'edit',
                  )
                ],
                if (widget.report!['workday_is_finalized'] == false) ...[
                  PopupMenuItem(
                    child: Text(l10n.wr_36),
                    value: 'fin',
                  )
                ],
                if (widget.report!['status'] == '1') ...[
                  PopupMenuItem(
                    child: Text(l10n.wr_37),
                    value: 'fin-send',
                  )
                ]
              ];
            },
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          elevation: 2.0,
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: HexColor('EA6012'),
          ),
          title: Image.asset(
            "assets/homelogo.png",
            width: 120,
            alignment: Alignment.topLeft,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WorkDayPage(
                          user: user,
                          workday: widget.workday,
                          contract: widget.contract,
                        )),
              );
            },
          ),
        ),
        /*  endDrawer: MenuLateral(
          user: user,
          //workday: this.widget.workday,
        ),*/
        body: ListView(
          // Column
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(left: 15, top: 10),
                    child: Image.asset('assets/002-data.png',
                        width: 50, color: HexColor('EA6012'))),
                Container(
                  margin: EdgeInsets.only(left: 10, top: 25),
                  child: Text('Detalle de Reporte sin Jornada',
                      style: TextStyle(
                          fontSize: 18,
                          color: HexColor('EA6012'),
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text('${l10n.date}:',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        )),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                        widget.report!['created'].toString() != 'null'
                            ? /*'${data['clock_in_start'].toString().substring(0, 10)}'*/ DateFormat(
                                    "MMMM d yyyy")
                                .format(
                                    DateTime.parse(widget.report!['created']))
                            : 'S/J',
                        style: TextStyle(
                          color: HexColor('EA6012'),
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        )),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(l10n.w_hours + ':',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        )),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                        widget.report!['worked_hours'].toString() != 'None'
                            ? widget.report!['worked_hours'].toString()
                            : 'S/H',
                        style: TextStyle(
                          color: HexColor('EA6012'),
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        )),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(l10n.w_quantity,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        )),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(datasj.length.toString(),
                        style: TextStyle(
                          color: HexColor('EA6012'),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        )),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text('Tiempo de StandBy:',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        )),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                        datasj.toString() != '[]'
                            ? datasj[0]['standby_duration']
                                .toString()
                                .substring(0, 5)
                            : 'Cargando...',
                        style: TextStyle(
                          color: HexColor('EA6012'),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        )),
                  ),
                ),
              ],
            ),
            if (_isSending) ...[
              Container(
                //margin: EdgeInsets.only(left: 5),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text('Enviando Reporte...',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      )),
                ),
              )
            ],
            if (_isFin) ...[
              Container(
                //margin: EdgeInsets.only(left: 5),
                child: const Align(
                  alignment: Alignment.topCenter,
                  child: Text('Finalizando Jornada...',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      )),
                ),
              )
            ],
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            isDataSJ == ''
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _getListOnTimeSJ(),
          ],
        ),
        floatingActionButton: PopupMenuButton(
          // color: HexColor('EA6012'),
          icon: Icon(
            Icons.menu,
            color: HexColor('EA6012'),
          ),
          onSelected: (value) {
            print('value');
            _sendReport();
            // your logic
          },
          itemBuilder: (BuildContext bc) {
            return [
              PopupMenuItem(
                child: Text("Enviar Reporte"),
                value: 'edit',
              )
            ];
          },
        ),
      );
    }
  }

  Widget _getListOnTime() {
    return Container(
        height: 550,
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return SizedBox(
                height: 25,
                child: GestureDetector(
                  onTap: () {
                    _showInfoWorker(data[index]);

                    /* if (data[index]['workday_entry_time'].toString() !=
                        'null') {
                      _showInfoWorker(data[index]);
                    }*/
                  },
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        //flex: 1,
                        child: Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(
                            left: 10,
                          ),
                          width: MediaQuery.of(context).size.width * 0.01,
                          child: data[index]['is_supervisor'] == true
                              ? Image.asset('assets/supervisor.png', width: 25)
                              : data[index]['is_lead'] == true
                                  ? Image.asset('assets/lead.png', width: 25)
                                  : data[index]['was_driver'] == true
                                      ? Image.asset('assets/driver.png',
                                          width: 25)
                                      : Icon(Icons.note),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          alignment: Alignment.topLeft,
                          width: MediaQuery.of(context).size.width * 0.19,
                          margin: EdgeInsets.only(top: 5),
                          child: Text(
                            'ID#${data[index]['btn_id']}',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          alignment: Alignment.topLeft,
                          width: MediaQuery.of(context).size.width * 0.80,
                          margin: EdgeInsets.only(top: 5),
                          child: Text(
                              '${data[index]['last_name']}'
                              ' '
                              '${data[index]['first_name']}',
                              style: TextStyle(
                                fontSize: 15,
                              )),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                            alignment: Alignment.topLeft,
                            width: MediaQuery.of(context).size.width * 0.05,
                            // margin: EdgeInsets.only(top: 10),
                            child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: HexColor('EA6012'),
                                ),
                                onPressed: () {
                                  _editInfoUnit(data[index]);
                                })),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                ));
          },
        ));
  }

  Widget _getListOnTimeSJ() {
    return Container(
        height: 550,
        child: ListView.builder(
          itemCount: datasj.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // _showInfoWorker(datasj[index]);
              },
              child: Container(
                  //margin: EdgeInsets.only(left: 10, top: 7),
                  child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Container(
                      //color: HexColor('009444'),
                      margin: EdgeInsets.only(left: 15),
                      alignment: Alignment.topLeft,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.98,
                      child: Row(
                        children: <Widget>[
                          Container(
                            //margin: EdgeInsets.only(left: 10),
                            child: datasj[index]['is_supervisor'] == true
                                ? Image.asset('assets/supervisor.png',
                                    width: 25)
                                : datasj[index]['is_lead'] == true
                                    ? Image.asset('assets/lead.png', width: 25)
                                    : datasj[index]['was_driver'] == true
                                        ? Image.asset('assets/driver.png',
                                            width: 25)
                                        : Icon(Icons.note),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Text(
                              'ID#${datasj[index]['btn_id']}',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 5),
                            child: Text(
                              '${datasj[index]['last_name']}' +
                                  ' ' '${datasj[index]['first_name']}',
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      //color: HexColor('009444'),
                      margin: EdgeInsets.only(
                        right: 15,
                      ),
                      alignment: Alignment.topRight,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.02,
                      child: Text(datasj[index]['standby_duration']
                          .toString()
                          .substring(0, 5)),
                    ),
                  ),
                ],
              )),
            );
          },
        ));
  }

  Widget _getListReview() {
    return Container(
        height: 550,
        child: ListView.builder(
          itemCount: datar.length,
          itemBuilder: (context, index) {
            return SizedBox(
                height: 25,
                child: GestureDetector(
                  onTap: () {
                    print('epale');
                    if (datar[index]['workday_entry_time'].toString() !=
                        'null') {
                      _showInfoWorker(datar[index]);
                    }
                  },
                  child: Container(
                      //margin: EdgeInsets.only(left: 10, top: 7),
                      child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 6,
                        child: Container(
                          //color: HexColor('009444'),
                          margin: EdgeInsets.only(left: 15),
                          alignment: Alignment.topLeft,
                          //height: MediaQuery.of(context).size.width * 0.1,
                          width: MediaQuery.of(context).size.width * 0.98,
                          child: Row(
                            children: <Widget>[
                              Container(
                                //margin: EdgeInsets.only(left: 10),
                                child: datar[index]['is_supervisor'] == true
                                    ? Image.asset('assets/supervisor.png',
                                        width: 25)
                                    : datar[index]['is_lead'] == true
                                        ? Image.asset('assets/lead.png',
                                            width: 25)
                                        : datar[index]['was_driver'] == true
                                            ? Image.asset('assets/driver.png',
                                                width: 25)
                                            : Icon(Icons.note),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(
                                  'ID#' + '' + '${datar[index]['btn_id']}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Text(
                                  '${datar[index]['last_name']}' +
                                      ' ' '${datar[index]['first_name']}',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Text(
                                  datar[index]['is_accepted'] == true
                                      ? 'Aprobado'
                                      : 'Pendiente',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: datar[index]['is_accepted'] == true
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          //color: HexColor('009444'),
                          margin: EdgeInsets.only(
                            right: 15,
                          ),
                          alignment: Alignment.topRight,
                          //height: MediaQuery.of(context).size.width * 0.1,
                          width: MediaQuery.of(context).size.width * 0.02,
                          child: Container(
                            // margin: EdgeInsets.only(left: 80),
                            child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: HexColor('EA6012'),
                                ),
                                onPressed: () {
                                  _editInfoUnit(datar[index]);
                                }),
                          ),
                        ),
                      ),
                    ],
                  )),
                ));
          },
        ));
  }

  Widget _getListExt() {
    return Container(
        height: 550,
        child: ListView.builder(
          itemCount: data1.length,
          itemBuilder: (context, index) {
            return SizedBox(
                height: 25,
                child: GestureDetector(
                  onTap: () {
                    if (data1[index]['workday_entry_time'].toString() !=
                        'null') {
                      _showInfoWorker(data1[index]);
                    }
                  },
                  child: Container(
                      //margin: EdgeInsets.only(left: 10, top: 7),
                      child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 6,
                        child: Container(
                          //color: HexColor('009444'),
                          margin: EdgeInsets.only(left: 15),
                          alignment: Alignment.topLeft,
                          //height: MediaQuery.of(context).size.width * 0.1,
                          width: MediaQuery.of(context).size.width * 0.98,
                          child: Row(
                            children: <Widget>[
                              Container(
                                //margin: EdgeInsets.only(left: 10),
                                child: Checkbox(
                                  activeColor: HexColor('EA6012'),
                                  value: _selectWorkers!
                                      .contains(data1[index]['id']),
                                  onChanged: (selected) {
                                    _onWorkerSelected(
                                      selected!,
                                      data1[index]['id'],
                                      data1[index]['first_name'],
                                      data1[index]['last_name'],
                                      data1[index]['btn_id'],
                                    );
                                  },
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(
                                  'ID#${data1[index]['btn_id']}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Text(
                                  '${data1[index]['first_name']}' +
                                      ' ' '${data1[index]['last_name']}',
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          //color: HexColor('009444'),
                          margin: EdgeInsets.only(
                            right: 15,
                          ),
                          alignment: Alignment.topRight,
                          //height: MediaQuery.of(context).size.width * 0.1,
                          width: MediaQuery.of(context).size.width * 0.02,
                          child: Container(
                            // margin: EdgeInsets.only(left: 80),
                            child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: HexColor('EA6012'),
                                ),
                                onPressed: () {
                                  _editInfoUnit(data1[index]);
                                }),
                          ),
                        ),
                      ),
                    ],
                  )),
                ));
          },
        ));
  }

  Widget _getListExtemporaneous() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
        height: 550,
        child: ListView.builder(
          itemCount: data1.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 10,
              margin: EdgeInsets.only(top: 10, left: 20, right: 20),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                            //color: HexColor('009444'),
                            margin: EdgeInsets.only(left: 15, top: 5),
                            alignment: Alignment.topLeft,
                            //height: MediaQuery.of(context).size.width * 0.1,
                            width: MediaQuery.of(context).size.width * 0.98,
                            child:
                                /*Row(
                              children: <Widget>[
                                data1[index]['is_supervisor'] == true
                                    ? Image.asset(
                                        'assets/supervisor.png',
                                        width: 25,
                                      )
                                    : data1[index]['was_lead'] == true
                                        ? Image.asset(
                                            'assets/lead.png',
                                            width: 25,
                                          )
                                        : data1[index]['was_driver'] == true
                                            ? Image.asset(
                                                'assets/driver.png',
                                                width: 25,
                                              )
                                            : Image.asset(
                                                'assets/worker.png',
                                                width: 25,
                                              ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'ID:' + ' ' + '${data1[index]['btn_id']}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: HexColor('EA6012'),
                                      fontSize: 17),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            )*/
                                Checkbox(
                              activeColor: HexColor('42E948'),
                              value:
                                  _selectWorkers!.contains(data1[index]['id']),
                              onChanged: (selected) {
                                _onWorkerSelected(
                                  selected!,
                                  data1[index]['id'],
                                  data1[index]['first_name'],
                                  data1[index]['last_name'],
                                  data1[index]['btn_id'],
                                );
                              },
                            )),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                            //color: HexColor('009444'),
                            //margin: EdgeInsets.only(left: 15, top: 5),
                            alignment: Alignment.topRight,
                            //height: MediaQuery.of(context).size.width * 0.1,
                            width: MediaQuery.of(context).size.width * 0.01,
                            child: Checkbox(
                              activeColor: HexColor('42E948'),
                              value:
                                  _selectWorkers!.contains(data1[index]['id']),
                              onChanged: (selected) {
                                _onWorkerSelected(
                                  selected!,
                                  data1[index]['id'],
                                  data1[index]['first_name'],
                                  data1[index]['last_name'],
                                  data1[index]['btn_id'],
                                );
                              },
                            )),
                      )
                    ],
                  ),
                  Divider(
                    color: Colors.grey[200],
                    // height: 1,
                    thickness: 2,
                    indent: 15,
                    endIndent: 15,
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 15),
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                              // margin: EdgeInsets.only(right: 70),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Nombre y Apellido:',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 18),
                                  ))),
                          Container(
                              margin: EdgeInsets.only(left: 5),
                              child: Text(
                                '${data1[index]['first_name']} ${data1[index]['last_name']}',
                                style: TextStyle(fontSize: 18),
                              )),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Text(
                              data[index]['is_accepted'] == true
                                  ? 'Aprobado'
                                  : 'Pendiente',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: data1[index]['is_accepted'] == true
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          )
                        ],
                      )),
                  Divider(
                    color: Colors.grey[200],
                    // height: 1,
                    thickness: 1,
                    indent: 15,
                    endIndent: 15,
                  ),
                  Divider(
                    color: Colors.grey[200],
                    // height: 1,
                    thickness: 1,
                    indent: 15,
                    endIndent: 15,
                  ),
                  Row(children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        //color: HexColor('009444'),
                        alignment: Alignment.center,
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: Column(
                          children: <Widget>[
                            Image.asset('assets/001-clock.png', width: 30),
                            SizedBox(
                              height: 5,
                            ),
                            const Text(
                              'Clock-in',
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                                '${data1[index]['clock_in'].substring(11, 16)}'),
                          ],
                        ),
                      ),
                    ),
                    Container(
                        height: 50,
                        child: VerticalDivider(color: Colors.grey[400])),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: Column(
                          children: <Widget>[
                            Image.asset('assets/entrada.png', width: 30),
                            SizedBox(
                              height: 5,
                            ),
                            Text(l10n.wr_4,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center),
                            Text(
                                '${data1[index]['workday_entry_time'].substring(11, 16)}'),
                          ],
                        ),
                      ),
                    ),
                    Container(
                        height: 50,
                        child: VerticalDivider(color: Colors.grey[400])),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'assets/002-clock-1.png',
                              width: 30,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text('Clock-out',
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center),
                            Text(
                                '${data1[index]['clock_out'].substring(11, 16)}'),
                          ],
                        ),
                      ),
                    ),
                    Container(
                        height: 50,
                        child: VerticalDivider(color: Colors.grey[400])),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: Column(
                          children: <Widget>[
                            Image.asset('assets/salida.png', width: 30),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              l10n.wr_5,
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                                '${data1[index]['workday_departure_time'].substring(11, 16)}'),
                          ],
                        ),
                      ),
                    )
                  ]),
                  Divider(
                    color: Colors.grey[200],
                    // height: 1,
                    thickness: 1,
                    indent: 15,
                    endIndent: 15,
                  ),

                  SizedBox(height: 10),
                  Row(children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        //color: HexColor('009444'),
                        alignment: Alignment.center,
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: Column(
                          children: <Widget>[
                            Image.asset('assets/horast.png', width: 30),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              l10n.wr_20,
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                                '${data1[index]['worked_hours'].substring(0, 2)}'),
                          ],
                        ),
                      ),
                    ),
                    Container(
                        height: 50,
                        child: VerticalDivider(color: Colors.grey[400])),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: Column(
                          children: <Widget>[
                            Image.asset('assets/lunch.png', width: 30),
                            SizedBox(
                              height: 5,
                            ),
                            Text('Almuerzo',
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center),
                            Text(
                                '${data1[index]['lunch_duration'].toString().substring(0, 5)}'),
                          ],
                        ),
                      ),
                    ),
                    Container(
                        height: 50,
                        child: VerticalDivider(color: Colors.grey[400])),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'assets/stand.png',
                              width: 30,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text('Stand By',
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center),
                            Text(
                                '${data1[index]['standby_duration'].toString().substring(0, 5)}'),
                          ],
                        ),
                      ),
                    ),
                    Container(
                        height: 50,
                        child: VerticalDivider(color: Colors.grey[400])),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: Column(
                          children: <Widget>[
                            Image.asset('assets/duracion.png', width: 30),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Viaje',
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                                '${data1[index]['travel_duration'].toString().substring(0, 5)}'),
                          ],
                        ),
                      ),
                    )
                  ]),

                  SizedBox(height: 10),
                  SizedBox(
                      width: 800,
                      height: 30,
                      // margin: EdgeInsets.only(left: 190),
                      //padding: EdgeInsets.only(left: 60, right: 60),
                      child: ElevatedButton(
                          onPressed: () {
                            _editInfoUnit(data1[index]);
                          },
                          child: const Text(
                            'Editar información',
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'OpenSans',
                            ),
                          ))),

                  //  SizedBox(height: 5)
                ],
              ),
            );
          },
        ));
  }
}
