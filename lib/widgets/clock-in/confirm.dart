import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:worker/providers/auth.dart';
import '../../providers/workday.dart';
import 'package:provider/provider.dart';

import '../../model/user.dart';
import '../widgets.dart';
import '../../model/workday.dart';
import 'cam_scan.dart';
import 'finish.dart';

class ConfirmClockIn extends StatefulWidget {
  final User? user;
  final int? workday;
  final String? geo;
  Map<String, dynamic>? contract;
  final Workday? work;

  ConfirmClockIn({this.user, this.workday, this.geo, this.contract, this.work});

  @override
  // ignore: library_private_types_in_public_api
  _ConfirmClockInState createState() =>
      _ConfirmClockInState(user!, workday!, geo!, contract!, work!);
}

class _ConfirmClockInState extends State<ConfirmClockIn> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  User user;
  int workday;
  String geo;
  Map<String, dynamic> contract;
  Workday work;

  Map<String, dynamic>? workdayMap;

  _ConfirmClockInState(
      this.user, this.workday, this.geo, this.contract, this.work);
  bool isLoading = false;

  User? _user;

  Future<dynamic> _submit() async {
    setState(() {
      isLoading = true;
    });

    try {
      Provider.of<WorkDay>(context, listen: false)
          .endClockIn(widget.workday, widget.geo,
              _user != null ? _user!.id : widget.user!.id)
          .then((response) {
        setState(() {
          isLoading = false;
        });
        if (response['status'] == '200') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FinishClockIn(
                      user: widget.user,
                      workday: widget.workday,
                      contract: widget.contract,
                      work: Workday.fromJson(response['workday']),
                    )),
          );
        } else {
          //_showErrorDialog('Verifique la información');
        }
      });
    } catch (error) {}
  }

  void _viewUser() {
    Provider.of<Auth>(context, listen: false).fetchUser().then((value) {
      print('response user');
      print(value);
      setState(() {
        _user = value['data'];
      });
    });
  }

  void _viewWorkDay() {
    Provider.of<WorkDay>(context, listen: false)
        .fetchWorkDayMap()
        .then((value) {
      setState(() {
        workdayMap = value;
      });
      print(workdayMap);
      //  getWorkdayOn(1);
    });
  }

  @override
  void initState() {
    _viewWorkDay();
    _viewUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
        body: Center(
            child: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            HexColor('FE7E1F'),
            HexColor('F57E07'),
            HexColor('F8AF04'),
            HexColor('F5AE07'),
            HexColor('FD821E'),
          ])),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
          Container(
            margin: EdgeInsets.only(left: 20),
            alignment: Alignment.topLeft,
            //height: MediaQuery.of(context).size.width * 0.1,
            child: Container(
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          Container(
              margin: EdgeInsets.only(left: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  'assets/in.png',
                  color: Colors.white,
                  width: 70,
                ),
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),

          if(workdayMap != null && workdayMap!['has_clocked_in'] == true)...[
               Container(
              margin: EdgeInsets.only(left: 30, right: 39),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  l10n.confirm,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.white),
                ),
              )),
          Container(
              margin: EdgeInsets.only(left: 30, right: 30, top: 5),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  l10n.clockin_21,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
          Container(
            margin: EdgeInsets.only(left: 30, right: 30),
            child: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/alerta.png',
                  width: 180,
                )),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.10,
          ),
          if (_user != null) ...[
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(left: 20, top: 10),
                    alignment: Alignment.topLeft,
                    //height: MediaQuery.of(context).size.width * 0.1,
                    width: MediaQuery.of(context).size.width * 0.50,
                    child: Container(
                      alignment: Alignment.topCenter,
                      //width: MediaQuery.of(context).size.width * 0.70,
                      child: isLoading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : ElevatedButton(
                              onPressed: _submit,
                              child: Text(
                                l10n.si,
                                style: TextStyle(
                                  color: HexColor('EA6012'),
                                  letterSpacing: 1,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(right: 20, top: 10),
                    alignment: Alignment.topRight,
                    //height: MediaQuery.of(context).size.width * 0.1,
                    width: MediaQuery.of(context).size.width * 0.50,
                    child: Container(
                      alignment: Alignment.topCenter,
                      //width: MediaQuery.of(context).size.width * 0.70,
                      child: isLoading
                          ? null
                          : ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                l10n.no,
                                style: TextStyle(
                                  color: HexColor('EA6012'),
                                  letterSpacing: 1,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ]
          ],

          if(workdayMap != null && workdayMap!['has_clocked_in'] == false)...[
             Container(
              margin: EdgeInsets.only(left: 30, right: 39),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'You havent been clockin all day',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.white),
                ),
              )),
          Container(
              margin: EdgeInsets.only(left: 30, right: 30, top: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text('You must decide whether to close the process or perform your clockin process',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              )),
                SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
          Container(
            margin: EdgeInsets.only(left: 30, right: 30),
            child: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/alerta.png',
                  width: 180,
                )),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.10,
          ),
          if (_user != null) ...[
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(left: 20, top: 10),
                    alignment: Alignment.topLeft,
                    //height: MediaQuery.of(context).size.width * 0.1,
                    width: MediaQuery.of(context).size.width * 0.50,
                    child: Container(
                      alignment: Alignment.topCenter,
                      //width: MediaQuery.of(context).size.width * 0.70,
                      child: isLoading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : ElevatedButton(
                              onPressed: _submit,
                              child: Text(
                                'End process',
                                style: TextStyle(
                                  color: HexColor('EA6012'),
                                  letterSpacing: 1,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(right: 20, top: 10),
                    alignment: Alignment.topRight,
                    //height: MediaQuery.of(context).size.width * 0.1,
                    width: MediaQuery.of(context).size.width * 0.50,
                    child: Container(
                      alignment: Alignment.topCenter,
                      //width: MediaQuery.of(context).size.width * 0.70,
                      child: isLoading
                          ? null
                          : ElevatedButton(
                              onPressed: () {
                                 Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => QRSCAN(
                                          user: widget.user,
                                          workday: widget.workday,
                                          work: widget.work,
                                          contract: widget.contract,
                                          wk: workdayMap,
                                          us: _user,
                                        )),
                              );           
                              },
                              child: Text(
                                'Make clockin',
                                style: TextStyle(
                                  color: HexColor('EA6012'),
                                  letterSpacing: 1,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ]

          ]


       
        ],
      ),
    )));
  }
}
