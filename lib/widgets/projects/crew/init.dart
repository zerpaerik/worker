import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:worker/model/config.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../../local/database_creator.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../global.dart';
import '../../../providers/crew.dart';
import 'list.dart';

class InitCrewReport extends StatefulWidget {
  Map<String, dynamic>? contract;

  InitCrewReport({this.contract});

  @override
  _InitCrewReportState createState() => _InitCrewReportState(contract);
}

class _InitCrewReportState extends State<InitCrewReport> {
  Map<String, dynamic>? contract;
  _InitCrewReportState(this.contract);

  Geolocator geolocator = Geolocator();

  Position? userLocation;
  String? geo;
  Map<String, dynamic>? crewCurrent;
  bool isLoading = false;
  List shifts = [];
  List categorys = [];

  var selectedValue;
  var selectedValue1;
  Config? config;

  int type = 0;
  List dataCategory = [];
  String cate = "";
  var selectedValuec;
  String? namec;
  int? category;
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
  DateTime? start_time;
  DateTime? end_time;

  String _time = "S/H";

  DateTime? hourClock; // init workday
  DateTime? hourClock1; // fin workday
  DateTime? hourClock2; // init lunch
  DateTime? hourClock3; // fin lunch
  DateTime? hourClock4; // init standby
  DateTime? hourClock5; // fin standby
  DateTime? hourClock6; // init travel
  DateTime? hourClock7; // fin travel
  DateTime? hourClock8; // init return
  DateTime? hourClock9;

// fin return
  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  Future<dynamic> getShifts() async {
    String token = await getToken();
    int locations = widget.contract!['id'];
    setState(() {});
    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/project/location/$locations/shift'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(utf8.decode(res.bodyBytes));
    print('es shifts');
    print(resBody);

    setState(() {
      shifts = resBody;
      if (shifts.length != 0) {
        selectedValue = shifts[0];
        type = shifts[0]['id'];
      }
    });
  }

  Future<dynamic> getCategory() async {
    String token = await getToken();
    int project = widget.contract!['project_id'];
    setState(() {});
    var res = await http.get(
        Uri.parse(
            ApiWebServer.server_name + '/api/v-1/project/$project/category'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(utf8.decode(res.bodyBytes));
    print('es categorys');
    print(resBody);

    setState(() {
      categorys = resBody;
      if (categorys.length != 0) {
        selectedValue1 = categorys[0];
        category = categorys[0]['id'];
      }
    });
  }

  Future<dynamic> submit() async {
    print('llego a pv');

    geo = '--- ---';

    setState(() {
      isLoading = true;
    });

    try {
      Provider.of<CrewProvider>(context, listen: false)
          .addCrew(widget.contract!['id'], geo, type, hourClock!, hourClock1!)
          .then((response) async {
        print('response add crew');
        print(response);
        await getCrew();
        setState(() {
          isLoading = false;
        });
        if (response['status'] == '201') {
          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ListCrew(
                      workday: response['workday']['id'],
                      contract: widget.contract,
                      shift: selectedValue,
                      crew: crewCurrent,
                    )),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ListCrew(
                      workday: response['workday']['id'],
                      contract: widget.contract,
                    )),
          );
        }
      });
    } catch (error) {}
  }

  Future<String> getCrew() async {
    String token = await getToken();
    setState(() {});
    var res = await http.get(
        Uri.parse(ApiWebServer.server_name + '/api/v-1/crew/current'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(utf8.decode(res.bodyBytes));

    print('es crew');
    print(resBody);

    setState(() {
      crewCurrent = resBody;
    });

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
            
            },
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    _getLocation().then((position) {
      userLocation = position;
    });
    getTodo(1);
    getCategory();
    getCrew();
    getShifts();
    setState(() {
      start_time = DateTime.parse(DateTime.now().toString());
      _time = DateFormat('hh:mm aa')
          .format(DateTime.parse((DateTime.now().toString())));
      hourClock = DateTime.parse((DateTime.now().toString()));
      end_time = DateTime.parse(DateTime.now().toString());

      hourClock1 = DateTime.parse((DateTime.now().toString()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
      width: double.infinity,
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
                  margin: EdgeInsets.only(left: 20),
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
                  margin: EdgeInsets.only(right: 20),
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
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Container(
              margin: EdgeInsets.only(left: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  'assets/002-data.png',
                  color: HexColor('EA6012'),
                  width: 60,
                ),
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          if (crewCurrent != null && crewCurrent!['location'] == null) ...[
            Container(
                margin: EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'New Crew Sheet',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 37,
                        color: HexColor('EA6012')),
                  ),
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Container(
                margin: EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    l10n.offer_location + ': ',
                    style: TextStyle(
                        //fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: HexColor('EA6012')),
                  ),
                )),
            Container(
                margin: EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    widget.contract!['name'],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: HexColor('EA6012')),
                  ),
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            if (categorys != null) ...[
              Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '${l10n.worker_category}: ',
                      style: TextStyle(
                          //fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: HexColor('EA6012')),
                    ),
                  )),
              Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: FormField(
                  builder: (state) {
                    return Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: HexColor('F8AF04'),
                        ),
                        child: DropdownButton(
                          isExpanded: true,
                          iconEnabledColor: HexColor('EA6012'),
                          hint: Text(
                            l10n.select,
                            style: TextStyle(color: HexColor('EA6012')),
                          ),
                          underline: Container(
                            height: 1,
                            color: HexColor('EA6012'),
                          ),
                          items: categorys.map((item) {
                            return DropdownMenuItem(
                              child: Text(
                                item['name'],
                                style: TextStyle(
                                    color: HexColor('EA6012'),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                              value: item,
                            );
                          }).toList(),
                          value: selectedValue1,
                          onChanged: (value) => setState(() {
                            selectedValue1 = value;
                            category = selectedValue1['id'];
                            state.didChange(value);
                          }),
                        ));
                  },
                ),
              )
            ],
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            if (shifts.length != 0) ...[
              Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      l10n.shift + ': ',
                      style: TextStyle(
                          //fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: HexColor('EA6012')),
                    ),
                  )),
              Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: FormField(
                  builder: (state) {
                    return Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: HexColor('F8AF04'),
                        ),
                        child: DropdownButton(
                          isExpanded: true,
                          iconEnabledColor: HexColor('EA6012'),
                          hint: Text(
                            l10n.select,
                            style: TextStyle(color: HexColor('EA6012')),
                          ),
                          underline: Container(
                            height: 1,
                            color: HexColor('EA6012'),
                          ),
                          items: shifts.map((item) {
                            return DropdownMenuItem(
                              child: Text(
                                item['name'],
                                style: TextStyle(
                                    color: HexColor('EA6012'),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                              value: item,
                            );
                          }).toList(),
                          value: selectedValue,
                          onChanged: (value) => setState(() {
                            selectedValue = value;
                            type = selectedValue['id'];
                            state.didChange(value);
                          }),
                        ));
                  },
                ),
              )
            ],
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                      //color: HexColor('009444'),
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(left: 20),
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.10,
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            'assets/entrada.png',
                            width: 40,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 5, top: 5),
                            child: Text(
                              l10n.wr_4,
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        ],
                      )),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                      //color: HexColor('009444'),
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(left: 10),
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            DateFormat("MMMM d yyyy")
                                .format(DateTime.parse(start_time.toString())),
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            _time,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      )),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                      //color: HexColor('009444'),
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.only(left: 30),
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.40,
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 35,
                            child: IconButton(
                              icon: Icon(Icons.calendar_today),
                              color: HexColor('EA6012'),
                              onPressed: () {
                                setState(() {});
                              },
                            ),
                          ),
                          SizedBox(
                            width: 35,
                            child: IconButton(
                              icon: Icon(Icons.timer),
                              color: HexColor('EA6012'),
                              onPressed: () async {
                                TimeOfDay? picketTime = await showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                );

                                if (picketTime != null) {
                                  DateTime selectedDateTime = DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day,
                                    picketTime.hour,
                                    picketTime.minute,
                                  );
                                  String formattedTime = DateFormat('hh:mm aa')
                                      .format(selectedDateTime);
                                  _time = formattedTime;
                                  setState(() {
                                    hourClock = selectedDateTime;
                                  }); // You can use the selectedDateTime as needed.
                                }
                              },
                            ),
                          )
                        ],
                      )),
                )
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.10,
            ),
            Container(
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(right: 30),
              //width: MediaQuery.of(context).size.width * 0.70,
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(HexColor('EA6012')),
                      ),
                      onPressed: () {
                        submit();
                      },
                      child: Text(
                        l10n.accept,
                        style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                    ),
            ),
          ],
          if (crewCurrent != null &&
              crewCurrent!['location'] != null &&
              crewCurrent!['has_report'] == false) ...[
            Container(
                margin: EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'CrewSheet',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 37,
                        color: HexColor('EA6012')),
                  ),
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.10,
            ),
            Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    l10n.to_crew2,
                    style: TextStyle(fontSize: 22, color: HexColor('EA6012')),
                  ),
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
            ),
            Container(
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(right: 30),
              //width: MediaQuery.of(context).size.width * 0.70,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(HexColor('EA6012')),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ListCrew(
                            crew: crewCurrent,
                            workday: crewCurrent!['id'],
                            contract: widget.contract,
                            shift: crewCurrent!['shift'])),
                  );
                },
                child: Text(
                  l10n.go_crew,
                  style: TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
              ),
            ),
          ],
          if (crewCurrent != null &&
              crewCurrent!['location'] != null &&
              crewCurrent!['has_report'] == true) ...[
            Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    shifts.length != 0 ? l10n.to_crew : l10n.to_crew1,
                    style: TextStyle(fontSize: 22, color: HexColor('EA6012')),
                  ),
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            if (shifts.isNotEmpty) ...[
              Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: FormField(
                  builder: (state) {
                    return Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: HexColor('F8AF04'),
                        ),
                        child: DropdownButton(
                          isExpanded: true,
                          iconEnabledColor: HexColor('EA6012'),
                          hint: Text(
                            l10n.select,
                            style: TextStyle(color: HexColor('EA6012')),
                          ),
                          underline: Container(
                            height: 1,
                            color: HexColor('EA6012'),
                          ),
                          items: shifts.map((item) {
                            return DropdownMenuItem(
                              child: Text(
                                item['name'],
                                style: TextStyle(color: HexColor('EA6012')),
                              ),
                              value: item,
                            );
                          }).toList(),
                          value: selectedValue,
                          onChanged: (value) => setState(() {
                            selectedValue = value;
                            type = selectedValue['id'];
                            state.didChange(value);
                          }),
                        ));
                  },
                ),
              )
            ],
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.10,
            ),
            Container(
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(right: 30),
              //width: MediaQuery.of(context).size.width * 0.70,
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(HexColor('EA6012')),
                      ),
                      onPressed: () {
                        submit();
                      },
                      child: Text(
                        l10n.accept,
                        style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                    ),
            ),
          ]
        ],
      ),
    )));
  }
}
