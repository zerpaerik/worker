import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/providers/workday.dart';
/*import 'package:worker/widgets/projects/crew/init.dart';
import 'package:package_info/package_info.dart';
import 'package:worker/widgets/projects/index.dart';
import 'package:worker/widgets/projects/project_list.dart';
import 'package:worker/widgets/travel/list.dart';
import 'package:worker/widgets/workers/index.dart';*/
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../clock-in/init.dart';
import '../clock-in/list.dart';
import '../clock-out/init.dart';
import '../global.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../model/config.dart';
import '../../model/workday_local.dart';
import '../../local/database_creator.dart';

import '../../model/user.dart';
import '../../model/workday.dart';
import '../../model/modules.dart';
import '../my-profile/config.dart';

class MenuLateral extends StatefulWidget {
  final User user;
  final Workday workday;
  Map<String, dynamic> contract;
  final Modules modules;

  MenuLateral(
      {required this.user,
      required this.workday,
      required this.contract,
      required this.modules});

  @override
  _MenuLateralState createState() =>
      _MenuLateralState(user, workday, contract, modules);
}

class _MenuLateralState extends State<MenuLateral> {
  late User user;
  late Workday workday;
  late Modules modules;
  late Map<String, dynamic> contract;

  _MenuLateralState(this.user, this.workday, this.contract, this.modules);
  late Workday _wd;
  late Modules module;
  late Config config;
  late WorkdayLocal worklocal;
  late Map<String, dynamic> workday_on;

  late Map<String, dynamic> travel_detail;
  late int travel;

  late Map<String, dynamic> dataContract;
  late Map<String, dynamic> contractDetail;
  late Map<String, dynamic> modules_get;
  late int _isSup = 0;

  late List data = [];

  Future<String?> getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<int?> getSupervisor() async {
    SharedPreferences sup = await SharedPreferences.getInstance();
    int? intValue = sup.getInt('intValue');
    setState(() {
      _isSup = intValue!;
    });
    return intValue;
  }

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<dynamic> _viewWorkDay() async {
    String? token = await getToken();

    final response = await http.get(
        Uri.parse('${ApiWebServer.server_name}/api/v-1/workday/get-current'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': "Token $token"
        });

    Map<String, dynamic> wdData = json.decode(utf8.decode(response.bodyBytes));
    setState(() {
      _wd = Workday.fromJson(wdData);
    });
  }

  Future<dynamic> getTravel() async {
    String? token = await getToken();
    var res = await http.get(
        Uri.parse('${ApiWebServer.server_name}/api/v-1/travel/1'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);

    if (res.statusCode == 200) {
      setState(() {
        travel = res.statusCode;
        //travel_detail = resBody;
      });
    } else {
      setState(() {
        travel = res.statusCode;
      });
      // print(res.statusCode);
    }
    print('travel data');
    print(travel);

    return "Sucess";
  }

  Future<dynamic> getM() async {
    String? token = await getToken();
    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/contract/modules-worker'),
        headers: {"Authorization": "Token $token"});

    if (res.statusCode == 200) {
      setState(() {
        module = Modules.fromJson(json.decode(res.body));
      });
    } else {
      // print(res.statusCode);
    }

    return "Sucess";
  }

  getTodo(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final todo = Config.fromJson(data.first);
    setState(() {
      config = todo;
    });
    return todo;
  }

  getContract(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable5}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final todo = data.first;
    setState(() {
      contractDetail = todo;
    });
    return contractDetail;
  }

  getWorkdayOn(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable6}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final todo = data.first;
    setState(() {
      workday_on = todo;
    });
    print(workday_on);
    return workday_on;
  }

  getWorkday(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable2}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final wk = WorkdayLocal.fromJson(data.first);
    setState(() {
      worklocal = wk;
    });
    return wk;
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text('No hay clock in en el dia'),
        titleTextStyle: TextStyle(
            color: HexColor('373737'),
            fontFamily: 'OpenSansRegular',
            fontWeight: FontWeight.bold,
            fontSize: 20),
        actions: <Widget>[
          TextButton(
            child: Text('Ok',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: HexColor('EA6012'))),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _getVersion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
      print('info de versión');
      print(_packageInfo.version);
      print(_packageInfo.buildNumber);
    });
  }

  Future<String> getSWData() async {
    String? token = await getToken();
    var res = await http.get(
        Uri.parse('${ApiWebServer.server_name}/api/v-1/expense/'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);

    if (res.statusCode == 200) {
      setState(() {
        data = resBody;
      });
    } else {
      // print(res.statusCode);
    }

    return "Sucess";
  }

  @override
  void initState() {
    this.getToken();
    this.getSupervisor();
    _getVersion();
    super.initState();
    getTodo(1);
    getContract(1);
    getWorkdayOn(1);
    getTravel();
    this.getM();
    this.getSWData();
    this._viewWorkDay();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: 210,
      child: Drawer(
          child: ListView(
        children: <Widget>[
          SizedBox(
            //height : 20.0,
            child: Row(children: <Widget>[
              Container(
                  margin: EdgeInsets.only(left: 30, top: 12),
                  child: Text(
                    l10n.option_menu,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  )),
            ]),
          ),
          Container(
              margin: EdgeInsets.only(left: 30, top: 5),
              child: Text(
                'Ver. ' + _packageInfo.version.toString(),
                style: TextStyle(
                  fontSize: 13,
                ),
              )),
          Container(
            margin: EdgeInsets.only(top: 2),
            child: Divider(),
          ),
          if (this.widget.modules != null) ...[
            if (config != null) ...[
              if (config.role == 'supervisor' || config.role == 'is_lead') ...[
                if (config.offline == null || config.offline == 'null') ...[
                  Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: TextButton.icon(
                              onPressed: () {
                                /* Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ActOffline(
                                            user: user,
                                            estatus: config.offline,
                                          )),
                                );*/
                              },
                              icon: ImageIcon(
                                AssetImage('assets/switch_offline.png'),
                                color: HexColor('EA6012'),
                              ),
                              label: Text(
                                'Activar Offline',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: HexColor('EA6012')),
                              )))),
                  Divider(),
                ],
                if (config.offline == 'SI') ...[
                  Container(
                      color: Colors.grey[700],
                      margin: EdgeInsets.only(left: 10),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: TextButton.icon(
                              onPressed: () {
                                /* Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => InactOffline(
                                            user: user,
                                            estatus: config.offline,
                                          )),
                                );*/
                              },
                              icon: ImageIcon(
                                AssetImage('assets/switch_offline.png'),
                                color: Colors.white,
                              ),
                              label: Text(
                                'Desactivar Offline',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              )))),
                  Divider(),
                  if (worklocal == null) ...[
                    Container(
                        color: Colors.grey[700],
                        margin: EdgeInsets.only(left: 10),
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: TextButton.icon(
                                onPressed: () {},
                                icon: ImageIcon(
                                  AssetImage('assets/clock-in-lat.png'),
                                  color: Colors.black,
                                ),
                                label: Text(
                                  'Clock-in Offline',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                )))),
                    Divider(),
                  ],
                ],
              ],
              if (config.role == 'supervisor' ||
                  this.widget.modules.clock_in_module == true) ...[
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => InitClockIn(
                                          user: user,
                                          contract: contractDetail,
                                          workday: workday_on,
                                        )),
                              );
                            },
                            icon: ImageIcon(
                              AssetImage('assets/clock-in-lat.png'),
                              color: Colors.black,
                            ),
                            label: Text(
                              'Clock Ins',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )))),
                Divider(),
              ],
              if (config.role == 'supervisor' ||
                  this.widget.modules.clock_out_module == true) ...[
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => InitClockOut(
                                          user: user,
                                          //workday: workday_on['workday_id'],
                                          work: widget.workday,
                                          contract: contractDetail,
                                          wk: workday_on,
                                        )),
                              );

                              /*   if (workday_on['clock_out_init'] == '') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InitClockOut(
                                        user: user,
                                        workday: this.widget.workday.id,
                                        work: this.widget.workday,
                                        contract: contractDetail,
                                        wk: workday_on,
                                      )),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ListClockOut(
                                        user: user,
                                        workday: this.widget.workday.id,
                                        workday_date:
                                            this.widget.workday.clock_out_end,
                                        contract: contractDetail,
                                        work: this.widget.workday,
                                      )),
                            );
                          }*/
                            },
                            icon: ImageIcon(
                              AssetImage('assets/clock-out-lat.png'),
                              color: Colors.black,
                            ),
                            label: Text(
                              'Clock Out',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )))),
                Divider(),
              ],
              if (config.role == 'supervisor' ||
                  this.widget.modules.workday_reports_module == true) ...[
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                            onPressed: () {
                              /*  if (workday_on['workday_id'] == '') {
                               Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WorkDayPage(
                                            user: user,
                                            workday: this.widget.workday.id,
                                            contract: contractDetail,
                                          )),
                                );
                              } else {
                                if (workday_on['clock_out_fin'] != '' &&
                                    workday_on['workday_other'] == 'true') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WorkDayPage(
                                              user: user,
                                              workday: this.widget.workday.id,
                                              contract: contractDetail,
                                            )),
                                  );
                                } else if (workday_on['clock_out_fin'] != '' &&
                                    workday_on['workday_other'] == 'false') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => InitWorkdayReport(
                                              workday: this.widget.workday,
                                              contract: contractDetail,
                                            )),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WorkDayPage(
                                              user: user,
                                              workday: this.widget.workday.id,
                                              contract: contractDetail,
                                            )),
                                  );
                                }
                              }*/
                            },
                            icon: ImageIcon(
                              AssetImage('assets/002-data.png'),
                              color: Colors.black,
                            ),
                            label: Text(
                              l10n.workday_report,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )))),
                Divider(),
              ],
              if (config.role == 'supervisor') ...[
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                            onPressed: () {
                              /* Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BannsLeadPage(
                                          user: user,
                                          contract: contractDetail,
                                        )),
                              );*/
                            },
                            icon: ImageIcon(
                              AssetImage('assets/amonestaciones.png'),
                              color: Colors.black,
                            ),
                            label: Text(
                              l10n.warnings,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )))),
                Divider(),
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                            onPressed: () {
                              /* Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TravelList(
                                          contract: contractDetail,
                                        )),
                              );*/
                            },
                            icon: ImageIcon(
                              AssetImage('assets/travel_report.png'),
                              color: Colors.black,
                            ),
                            label: Text(
                              l10n.travels,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )))),
                Divider(),
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                            onPressed: () {
                              /*  Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ListTravelReport(
                                        // user: user,
                                        //contract: contractDetail,
                                        )),
                              );*/
                            },
                            icon: ImageIcon(
                              AssetImage('assets/travel_report.png'),
                              color: Colors.black,
                            ),
                            label: Text(
                              l10n.travel_report,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )))),
                Divider(),
              ],
              if (config.role == 'supervisor' ||
                  this.widget.modules.expenses_module == true) ...[
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                            onPressed: () {
                              /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ExpensesPage(
                                        user: user, contract: contractDetail)),
                              );*/
                            },
                            icon: ImageIcon(
                              AssetImage('assets/gastos.png'),
                              color: Colors.black,
                            ),
                            label: Text(
                              l10n.expenses,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            )))),
                Divider(),
              ],
              if (config.role == 'supervisor') ...[
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                            onPressed: () {
                              /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ListWorkersGeneric(
                                          user: user,
                                          contract: contractDetail,
                                        )),
                              );*/
                            },
                            icon: ImageIcon(
                              AssetImage('assets/work.png'),
                              color: Colors.black,
                            ),
                            label: Text(
                              l10n.workers,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )))),
                Divider(),
              ],
            ],
            if (config != null) ...[
              if (config.id_type == 'business' || _isSup == 1) ...[
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                            onPressed: () {
                              /* Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProjectListN()),
                              );*/
                            },
                            icon: ImageIcon(
                              AssetImage('assets/proyectos.png'),
                              color: Colors.black,
                            ),
                            label: Text(
                              l10n.projects,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )))),
                Divider(),
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                            onPressed: () {
                              /*  Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProjectList()),
                              );*/
                            },
                            icon: ImageIcon(
                              AssetImage('assets/proyectos.png'),
                              color: Colors.black,
                            ),
                            label: Text(
                              l10n.contracts,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )))),
                Divider(),
                /*   Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: FlatButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddressProfile()),
                              );
                            },
                            icon: ImageIcon(
                              AssetImage('assets/proyectos.png'),
                              color: Colors.black,
                            ),
                            label: Text(
                              'Validacion de direccion',
                              style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                fontSize: 16,
                              )),
                            )))),
                Divider(),*/
              ]
            ],
            Container(
                margin: EdgeInsets.only(left: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ConfigPage(
                                      user: widget.user,
                                    )),
                          );
                        },
                        icon: const ImageIcon(
                          AssetImage('assets/005-gear.png'),
                          color: Colors.black,
                        ),
                        label: Text(
                          l10n.setting,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        )))),
            Divider(),
          ]
        ],
      )),
    );
  }
}
