import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:worker/providers/auth.dart';
import 'package:worker/widgets/clock-out/cam_scan_out.dart';
import '../../providers/workday.dart';
import 'package:provider/provider.dart';

import '../../model/user.dart';
import '../../model/workday.dart';
import '../widgets.dart';
import 'finish.dart';
import 'list.dart';
import 'make_in_out.dart';
import 'make_out.dart';

class ConfirmClockOut extends StatefulWidget {
  final User? user;
  final int? workday;
  final String? geo;
  Map<String, dynamic>? contract;
  final Workday? work;

  ConfirmClockOut(
      {this.user, this.workday, this.geo, this.contract, this.work});

  @override
  _ConfirmClockOutState createState() =>
      _ConfirmClockOutState(user!, workday!, geo!, contract!, work!);
}

class _ConfirmClockOutState extends State<ConfirmClockOut> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  User user;
  int workday;
  String geo;
  Map<String, dynamic> contract;
  Workday work;
  _ConfirmClockOutState(
      this.user, this.workday, this.geo, this.contract, this.work);
  bool isLoading = false;
  User? _user;
  Map<String, dynamic>? workdayMap;

  Future<dynamic> _submit() async {
    setState(() {
      isLoading = true;
    });
    print(this.widget.workday);
    try {
      Provider.of<WorkDay>(context, listen: false)
          .endClockOut(this.widget.workday, this.widget.geo,
              _user != null ? _user!.id : widget.user!.id)
          .then((response) {
        setState(() {
          isLoading = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FinishClockOut(
                    user: _user,
                    workday: this.widget.workday,
                    contract: this.widget.contract,
                    work: this.widget.work,
                  )),
        );
      });
    } catch (error) {}
  }

  void _viewUser() {
    Provider.of<Auth>(context, listen: false).fetchUser().then((value) {
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
    _viewUser();
    _viewWorkDay();
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
          if (workdayMap != null && workdayMap!['has_clocked_out'] == true) ...[
            Container(
                margin: EdgeInsets.only(left: 30, right: 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    l10n.clockout_23,
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
                    l10n.clockout_24,
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
          if (workdayMap != null &&
              workdayMap!['has_clocked_in'] == true &&
              workdayMap!['has_clocked_out'] == false) ...[
            Container(
                margin: EdgeInsets.only(left: 30, right: 39),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'You havent been clockout all day',
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
                  child: Text(
                    'You must decide whether to close the process or perform your clockout process',
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
                  /*  Expanded(
                    flex: 1,
                    child: Container(
                      margin:const EdgeInsets.only(left: 20, top: 10),
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
                  ),*/
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
                                        builder: (context) => MakeOut(
                                              user: widget.user,
                                              workday: widget.workday,
                                              work: widget.work,
                                              contract: widget.contract,
                                              wk: workdayMap,
                                            )),
                                  );
                                },
                                child: Text(
                                  'Make clockout',
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
          ],

          ///
          ///

          if (workdayMap != null &&
              workdayMap!['has_clocked_in'] == false &&
              workdayMap!['has_clocked_out'] == false) ...[
            Container(
                margin: EdgeInsets.only(left: 30, right: 39),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'You don’t have clock in or clock out today.',
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
                  child: Text(
                    'You must decide whether to close the process or perform your clock process',
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
                      margin: const EdgeInsets.only(left: 20, top: 10),
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
                                        builder: (context) => MakeInOut(
                                              user: widget.user,
                                              workday: widget.workday,
                                              work: widget.work,
                                              contract: widget.contract,
                                              wk: workdayMap,
                                              init: false,
                                            )),
                                  );
                                },
                                child: Text(
                                  'Make clock in',
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

          ///
        ],
      ),
    )));
  }
}
