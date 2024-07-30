import 'dart:convert';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/model/user.dart';
import 'package:worker/model/workday.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../global.dart';
import 'cam_scan.dart';
import 'detail.dart';

class AddWorkerScam extends StatefulWidget {
  final User? user;
  final int? workday;
  final DateTime? workdayDate;
  Map<String, dynamic>? contract;
  final Workday? work;
  Map<String, dynamic>? wk;
  final User? us;

  AddWorkerScam(
      {required this.user,
      required this.workday,
      this.workdayDate,
      this.contract,
      this.work,
      this.wk,
      this.us});

  @override
  State<StatefulWidget> createState() =>
      _AddWorkerScamtate(user, workday, workdayDate, contract, work, wk, us);
}

class _AddWorkerScamtate extends State<AddWorkerScam> {
  User? user;
  int? workday;
  DateTime? workdayDate;
  Map<String, dynamic>? contract;
  Workday? work;
  Map<String, dynamic>? wk;
  User? us;
  List? categorys = [];
  String? selectedValue;
  int worker_category = 0;
  bool isLoading = false;

  _AddWorkerScamtate(this.user, this.workday, this.workdayDate, this.contract,
      this.work, this.wk, this.us);
  bool Done_Button = false;
  var qrText = "";
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool scanning = false;
  bool add = false;
  final GlobalKey<FormState> _formKey = GlobalKey();

  Future<String?> getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  void _showErrorDialogADD(String message, int worker) {
    print(message);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: EdgeInsets.all(32.0),
        //title: Text(message),
        content: Column(
          children: <Widget>[
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: HexColor('EA6012'))),
            Container(
              child: Text('Add worker',
                  style: TextStyle(
                    fontSize: 18,
                  )),
            ),
            Container(
              // margin: EdgeInsets.only(left: 5, right: 5),
              child: FormField(
                builder: (state) {
                  return Theme(
                      data: Theme.of(context).copyWith(
                          //canvasColor: HexColor('F8AF04'),
                          ),
                      child: DropdownButton(
                        isExpanded: true,
                        iconEnabledColor: HexColor('EA6012'),
                        hint: Text(
                          'Select',
                          // style: TextStyle(color: Colors.white),
                        ),
                        underline: Container(
                          height: 1,
                          color: Colors.white,
                        ),
                        items: categorys!.map((item) {
                          return DropdownMenuItem(
                            child: Text(
                              item['name'],
                              //style: TextStyle(color: Colors.white),
                            ),
                            value: item,
                          );
                        }).toList(),
                        value: selectedValue,
                        onChanged: (value) => setState(() {
                          selectedValue = value as String?;
                          //worker_category = value!['id'] as int;
                          state.didChange(value);
                        }),
                      ));
                },
              ),
            ),
          ],
        ),
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: HexColor('EA6012')),
        actions: <Widget>[
          TextButton(
              child: Text('Add project'),
              onPressed: () {
                Navigator.of(ctx).pop();
                addProyect(worker);
                //Navigator.of(ctx).pop();
                //_submitOffer(worker);
              })
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    print(message);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: HexColor('EA6012'))),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => QRSCAN(
                          user: widget.user,
                          workday: widget.workday,
                          work: widget.work,
                          contract: widget.contract,
                          wk: widget.wk,
                          us: widget.user,
                        )),
              );
            },
          )
        ],
      ),
    );
  }

  Future<String> getSWData() async {
    String? token = await getToken();

    final String url =
        '${ApiWebServer.server_name}/api/v-1/worker-category/${widget.contract!['contract_id']}';

    var res = await http
        .get(Uri.parse(url), headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);

    setState(() {
      categorys = resBody;
    });
    return "Sucess";
  }

  Future<dynamic> addProyect(int worker) async {
    String? token = await getToken();
    String contract = widget.contract!['contract_id'].toString();

    setState(() {
      add = true;
    });
    //print(contract);
    final response = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/user/check-worker-profile/$worker/$contract/'),
        headers: {"Authorization": "Token $token"});
    setState(() {});

    var resBody = json.decode(response.body);
    setState(() {
      add = false;
    });

    if (resBody['code'] == 'WAC') {
      User _user = User.fromJson(resBody);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailClockIn(
                  user: _user,
                  workday: widget.workday,
                  lat: 'lat',
                  long: 'long',
                  contract: this.widget.contract,
                  wk: widget.wk,
                  work: this.widget.work,
                  us: this.widget.us,
                )),
      );
    } else if (resBody['code'] == 'WDC') {
      _showErrorDialog(resBody['msg']);
    } else {
      _showErrorDialog('Error');
    }
  }

  void _showReads() {
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
                'assets/cargando.gif',
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
                child: Text('Adding to project'))
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
    super.initState();
    getSWData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Form(
          key: _formKey,
          child: SingleChildScrollView(
              child: Container(
                  child: Column(children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            Container(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: HexColor('EA6012'),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: EdgeInsets.only(left: 20),
                    alignment: Alignment.topLeft,
                    //height: MediaQuery.of(context).size.width * 0.1,
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Image.asset(
                            'assets/in.png',
                            color: Colors.black,
                            width: 40,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              l10n.detail_ci,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(this.widget.contract!['contract_name'],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: HexColor('EA6012'))),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text('BTN',
                    style: TextStyle(
                      fontSize: 17,
                    )),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(l10n.worker_data,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: HexColor('EA6012'))),
              ),
            ),
            Container(
                margin: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text('Emplooy ID:${user!.btn_id}',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      )),
                )),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(l10n.clockin_23,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: HexColor('EA6012'))),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: FormField(
                builder: (state) {
                  return Theme(
                      data: Theme.of(context).copyWith(
                          //canvasColor: HexColor('F8AF04'),
                          ),
                      child: DropdownButton(
                        isExpanded: true,
                        iconEnabledColor: HexColor('EA6012'),
                        hint: Text(
                          l10n.select,
                          // style: TextStyle(color: Colors.white),
                        ),
                        underline: Container(
                          height: 1,
                          color: Colors.white,
                        ),
                        items: categorys!.map((item) {
                          return DropdownMenuItem(
                            child: Text(
                              item['name'],
                              //style: TextStyle(color: Colors.white),
                            ),
                            value: item,
                          );
                        }).toList(),
                        value: selectedValue,
                        onChanged: (value) => setState(() {
                          selectedValue = value as String?;
                          // worker_category = value!['id'];
                          state.didChange(value);
                        }),
                      ));
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Image.asset(
                    'assets/clock1.png',
                    width: 30,
                    color: Colors.black,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, top: 12),
                  child: Text(
                    l10n.clockin_26,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Image.asset(
                    'assets/verificado.png',
                    width: 28,
                    color: Colors.black,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                    l10n.clockin_24,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                    l10n.si,
                    style: TextStyle(
                        fontSize: 17,
                        color: HexColor('EA6012'),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.10,
            ),
            Container(
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(right: 30, bottom: 15),
              // margin: EdgeInsets.only(left:15),
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: () {},

                      //  color: HexColor('EA6012'),
                      child: Text(
                        l10n.accept,
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
            ),
          ])))),
    );
  }
}

class Paintest extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.grey.withOpacity(0.9), BlendMode.dstOut);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class Cliptest extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    print(size);
    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(10, size.height / 2 - 95, size.width - 20, 200),
          Radius.circular(5)));
    return path;
  }

  @override
  bool shouldReclip(oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}
