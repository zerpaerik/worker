import 'dart:convert';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:worker/providers/workday.dart';
import 'package:worker/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:worker/widgets/workday-report/init_sj.dart';

import '../../model/user.dart';
import '../../model/workday_register.dart';

import '../dashboard/index.dart';
import '../global.dart';
import '../widgets.dart';
import 'detail.dart';

class WorkDayPage extends StatefulWidget {
  static const routeName = '/workday-page';
  final User? user;
  final int? workday;
  Map<String, dynamic>? contract;

  WorkDayPage({this.user, this.workday, this.contract});

  @override
  _WorkDayPageState createState() => _WorkDayPageState(user, workday, contract);
}

class _WorkDayPageState extends State<WorkDayPage> {
  User? user;
  int? workday;
  Map<String, dynamic>? contract;

  _WorkDayPageState(this.user, this.workday, this.contract);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int? selectedRadio;
  bool _isData = false;
  bool _isSending = false;

  final String url =
      '${ApiWebServer.server_name}/api/v-1/workday/80/workday-report/worker-report/';

  //List data = List();
  List data = [];
  Map<String, dynamic>? dataw;
  Map<String, dynamic>? data1;

  String isData = '';
  bool _isEdit = false;
  bool _selectw = false;
  // FOR EDIT DATA

  var drivers;
  final _form = GlobalKey<FormState>();

  // ignore: unused_field
  int _selectedIndex = 4;

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  void _showScaffold(String message) {
    /* _scaffoldKey.currentState!.showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: HexColor('EA6012'),
    ));*/
  }

  getContract() async {
    SharedPreferences contract = await SharedPreferences.getInstance();
    //Return String
    int? intValue = contract.getInt('intValue');
    return intValue;
  }

  Future<dynamic> _sendReportT(id) async {
    setState(() {
      _isSending = true;
    });
    print('se fue');
    try {
      Provider.of<WorkDay>(context, listen: false)
          .sendReport(
        id,
      )
          .then((response) {
        setState(() {});
        if (response == 200) {
          _showviewRequest();

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WorkDayPage(
                      user: user,
                      contract: widget.contract,
                      workday: widget.workday,
                    )),
          );
          setState(() {
            _isSending = false;
          });
        } else {
          setState(() {
            _isSending = false;
          });
        }
      });
    } catch (error) {}
    /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePartOblig2()),
          );*/
  }

  Future<dynamic> _sendReportC(id) async {
    setState(() {
      _isSending = true;
    });
    print('se fue');
    try {
      Provider.of<WorkDay>(context, listen: false)
          .sendReportC(
        id,
      )
          .then((response) {
        setState(() {});
        if (response == 200) {
          _showviewRequest();

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WorkDayPage(
                      user: user,
                      contract: widget.contract,
                      workday: widget.workday,
                    )),
          );

          setState(() {
            _isSending = false;
          });
        } else {
          setState(() {
            _isSending = false;
          });
        }
      });
    } catch (error) {}
    /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePartOblig2()),
          );*/
  }

  Future<String> getSWData() async {
    String token = await getToken();
    String contract = widget.contract!['contract_id'].toString();
    int? workday = widget.workday;
    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/workday/$contract/workday-report/'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);
    print(resBody);

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
        print('hay data erik');
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

  void _showviewRequest1(data) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(
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
            child: Text('View',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: HexColor('EA6012'),
                  fontSize: 17,
                )),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailWorkDay(
                        user: user,
                        workday: data['workday'],
                        report: data,
                        contract: widget.contract)),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPrev() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(
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
                child: Text(l10n.wr_24))
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
    selectedRadio = 0;
    super.initState();
  }

  void _showviewRequest() {
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
                child: Text(l10n.wr_26))
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

  void _showSend(id) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        content: Container(
          height: 150,
          width: 300,
          child: Column(
            children: <Widget>[
              Container(
                  alignment: Alignment.topCenter,
                  child: Text(l10n.wr_27,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ))),
              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Container(
                    child: IconButton(
                        icon: ImageIcon(
                          AssetImage(
                            'assets/aplicar.png',
                          ),
                          color: HexColor('EA6012'),
                        ),
                        onPressed: () {
                          _sendReportT(id);
                        }),
                  ),
                  Container(
                    child: TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _showInputDialog(l10n.wr_28, id, 1);

                          //_takePicture1();
                        },
                        child: Container(
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(l10n.wr_29,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ))))),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    child: IconButton(
                        icon: ImageIcon(
                          AssetImage(
                            'assets/aplicar.png',
                          ),
                          color: HexColor('EA6012'),
                        ),
                        onPressed: () {
                          _sendReportC(id);
                        }),
                  ),
                  Container(
                    child: TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _showInputDialog(l10n.wr_31, id, 2);
                        },
                        child: Container(
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(l10n.wr_30,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ))))),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInputDialog(String title, id, tipo) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        context: context,
        builder: (ctx) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Text(title,
                    style: TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center),
              ),
              SizedBox(
                height: 10,
              ),
              Image.asset(
                'assets/alert.png',
                width: 90,
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                        //margin: EdgeInsets.only(left: 20),
                        alignment: Alignment.center,
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 1.0),
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: OutlinedButton(
                            //onPressed: () => select("English"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  width: 5.0, color: HexColor('EA6012')),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                            ),
                            child: Text(
                              'No',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: HexColor('EA6012')),
                            ),
                          ),
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                        //margin: EdgeInsets.only(left: 20),
                        alignment: Alignment.center,
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 1.0),
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (tipo == 1) {
                                // _sendingReport();
                                _sendReportT(id);
                              } else {
                                _sendReportC(id);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  width: 5.0, color: HexColor('EA6012')),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                            ),
                            child: Text(
                              'Yes',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: HexColor('EA6012')),
                            ),
                          ),
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: _scaffoldKey,
      body: !_isData
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : isData == 'Y'
              ? ListView(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.only(left: 5),
                            alignment: Alignment.topLeft,
                            //height: MediaQuery.of(context).size.width * 0.1,
                            width: MediaQuery.of(context).size.width * 0.50,
                            child: Container(
                              child: Text(''),
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
                                  //Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DashboardHome(
                                              noti: false,
                                              data: {},
                                            )),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Image.asset('assets/002-data.png',
                            width: 50, color: HexColor('EA6012')),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Container(
                      margin: EdgeInsets.only(left: 30, right: 30),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(l10n.wr_1,
                            style: TextStyle(
                                fontSize: 25,
                                color: HexColor('EA6012'),
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    if (_isSending) ...[
                      Container(
                        //margin: EdgeInsets.only(left: 5),
                        child: const Align(
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
                    SizedBox(
                      height: 10,
                    ),
                    SingleChildScrollView(
                      child: _getListWorkDay(),
                    )
                  ],
                )
              : _getBase()
      // ignore: unrelated_type_equality_checks
      ,
      /*  bottomNavigationBar: AppBarButton(
        user: user,
        selectIndex: 0,
      ),*/
      /* floatingActionButton: FloatingActionButton(
        heroTag: "btn3",
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 40,
        ),
        //backgroundcolor: HexColor('EA6012'),
        onPressed: () {
          /*  Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => InitWorkdayReportSJ(
                      contract: widget.contract,
                    )),
          );*/
          /* Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewWorkdayReportBase(
                        user: user,
                        workday: this.widget.workday,
                      )),
            );*/
        },
      ),*/
    );
  }

  Widget _getBase() {
    return Center(
      child: Container(
          margin: EdgeInsets.only(top: 50),
          child: Column(children: <Widget>[
            /* Image.asset(
              'assets/certificate.png',
              width: 150,
            ),*/
            SizedBox(height: 15),
            Image.asset(
              'assets/workday.png',
              width: 180,
            ),
            SizedBox(
              height: 20,
            ),
            Text('Reporte del dia',
                style: TextStyle(
                    fontSize: 30,
                    color: HexColor('EA6012'),
                    fontWeight: FontWeight.bold)),
            SizedBox(height: MediaQuery.of(context).size.width * 0.02),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: const Text(
                'Agrega un nuevo reporte seleccionando el botón en la parte inferior derecha de tu pantalla.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.justify,
              ),
            )
          ])),
    );
  }

  Widget _getListWorkDay() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final l10n = AppLocalizations.of(context)!;

            return Card(
              /* shape: (selectedIndex == position)
            ? RoundedRectangleBorder(
                side: BorderSide(color: Colors.green, width: 2))
            : null,*/
              //elevation: 6,
              margin: EdgeInsets.only(top: 10, left: 20, right: 20),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Container(
                          //color: HexColor('009444'),
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(left: 10),
                          //height: MediaQuery.of(context).size.width * 0.1,
                          width: MediaQuery.of(context).size.width * 0.90,
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      DateFormat("MMMM d yyyy").format(
                                          DateTime.parse(
                                              data[index]['created'])),
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: HexColor('EA6012'),
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.left,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                        widget.contract!['contract_name'],
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                              Container(
                                child: Text(data[index]['time_zone'].toString(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: HexColor('EA6012'),
                                        fontWeight: FontWeight.bold)),
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Text('${l10n.wr_20}: ',
                                        style: TextStyle(
                                          fontSize: 16,
                                        )),
                                  ),
                                  Container(
                                    child: Text(
                                        data[index]['worked_hours']
                                                        .toString() ==
                                                    'None' ||
                                                data[index]['worked_hours']
                                                        .toString() ==
                                                    '0:00:00'
                                            ? 'S/H'
                                            : data[index]['worked_hours']
                                                        .toString()
                                                        .length >
                                                    3
                                                ? data[index]['worked_hours']
                                                    .toString()
                                                : data[index]['worked_hours']
                                                    .toString(),
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: HexColor('EA6012'),
                                            fontWeight: FontWeight.bold)),
                                  )
                                ],
                              )
                              /*Text(
                                  'Horas T: ' +
                                      data[index]['worked_hours']
                                          .toString()
                                          .substring(0, 4),
                                  style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                          fontSize: 16,
                                          color: HexColor('EA6012'),
                                          fontWeight: FontWeight.bold)))*/
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          //color: HexColor('009444'),
                          alignment: Alignment.topRight,
                          margin: EdgeInsets.only(right: 10, top: 5),
                          //height: MediaQuery.of(context).size.width * 0.1,
                          width: MediaQuery.of(context).size.width * 0.10,
                          child: data[index]['status'].toString() == '1'
                              ? Text(
                                  l10n.wr_21,
                                  style: TextStyle(
                                      color: Colors.red,
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                )
                              : data[index]['status'].toString() == '2'
                                  ? Text(l10n.wr_22,
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          //fontWeight: FontWeight.bold,
                                          fontSize: 16))
                                  : Text(l10n.wr_23,
                                      style: const TextStyle(
                                          color: Colors.green,
                                          //  fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                        ),
                      ),
                    ],
                  ),

                  Divider(
                    color: Colors.grey[200],
                    // height: 1,
                    thickness: 2,
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
                            Text(
                              'Clock-in',
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            Text(data[index]['clock_in_start'].toString() ==
                                    'null'
                                ? 'S/J'
                                : '${data[index]['clock_in_start'].toString().substring(11, 16)}' /*'${data[index]['clock_in_start'].toString().substring(11, 16)}'*/),
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
                            Text(/* '${data[index]['clock_out_start'].toString().substring(11, 16)}'*/ data[
                                            index]['clock_out_start']
                                        .toString() ==
                                    'null'
                                ? 'S/J'
                                : '${data[index]['clock_out_start'].toString().substring(11, 16)}'),
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
                            Text(data[index]['workday_entry_time'].toString() !=
                                    'null'
                                ? '${data[index]['workday_entry_time'].substring(11, 16)}'
                                : 'S/J'),
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
                            Text(data[index]['workday_departure_time']
                                        .toString() !=
                                    'null'
                                ? '${data[index]['workday_departure_time'].substring(11, 16)}'
                                : 'S/J'),
                          ],
                        ),
                      ),
                    ),
                  ]),
                  SizedBox(
                    height: 10,
                  ),

                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: HexColor('F1F1F2'),
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.width * 0.1,
                          width: MediaQuery.of(context).size.width * 0.33,
                          child: TextButton(
                              child: Text(l10n.wr_17,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: HexColor('EA6012'),
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                if (_isSending) {
                                  _showScaffold(l10n.wr_24);
                                  //_showPrev();
                                } else {
                                  if (data[index]['had_workday'] == true) {
                                    /*  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EditWorkdayReport1(
                                                user: user,
                                                workday: widget.workday,
                                                contract: widget.contract,
                                                report: data[index],
                                              )),
                                    );*/
                                  } else {}
                                }
                              }),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: HexColor('F1F1F2'),
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.width * 0.1,
                          width: MediaQuery.of(context).size.width * 0.33,
                          child: TextButton(
                            child: Text(l10n.wr_18,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: HexColor('EA6012'),
                                    fontWeight: FontWeight.bold)),
                            onPressed: () {
                              if (_isSending) {
                                _showScaffold(l10n.wr_24);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailWorkDay(
                                          user: user,
                                          workday: data[index]['workday'],
                                          report: data[index],
                                          contract: widget.contract)),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: HexColor('F1F1F2'),
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.width * 0.1,
                          width: MediaQuery.of(context).size.width * 0.33,
                          child: TextButton(
                            child: Text(l10n.wr_19,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: data[index]['ready_to_sent'] == true
                                        ? HexColor('EA6012')
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            onPressed: () {
                              if (_isSending) {
                                _showScaffold(
                                    "Ya se está ejecutando el envío del reporte.");
                              } else {
                                if (data[index]['ready_to_sent'] == true) {
                                  _showSend(data[index]['id']);
                                } else {
                                  _showviewRequest1(data[index]);
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      /*  Expanded(
                        flex: 1,
                        child: Container(
                          color: HexColor('F1F1F2'),
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.width * 0.1,
                          width: MediaQuery.of(context).size.width * 0.33,
                          child: IconButton(
                            icon: ImageIcon(AssetImage('assets/resumen.png'),
                                color: HexColor('EA6012')),
                            tooltip: 'Ver Resumen',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SummaryWorkDay(
                                          user: user,
                                          report: data[index]['id'],
                                          contract: this.widget.contract,
                                        )),
                              );
                            },
                          ),
                        ),
                      ),*/
                    ],
                  ),

                  //  SizedBox(height: 5)
                ],
              ),
            );
          },
        ));
  }

  // ignore: unused_element
}
