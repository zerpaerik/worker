import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' show DateFormat;
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:worker/widgets/projects/project_list.dart';
//import 'package:worker/widgets/workers/index_g.dart';
import 'package:worker/providers/crew.dart';

import '../global.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//import '../workers/index_g.dart';
import 'crew/init.dart';
import 'crewsheets/detail.dart';
import 'crewsheets/edit_general/step_1.dart';
import 'detail.dart';

class ContractList extends StatefulWidget {
  final Map<String, dynamic>? location;

  ContractList({this.location});
  @override
  _ContractListState createState() => _ContractListState(location);
}

class _ContractListState extends State<ContractList> {
  Map<String, dynamic>? project;
  _ContractListState(this.project);
  List listProjects = [];
  List datar = [];
  List dataw = [];
  String isData = '';
  String isDataR = '';
  String isDataW = '';
  TextEditingController? tc;
  DateTime? hourClock;
  bool _isSending = false;
  var rows = [];
  List results = [];
  String query = '';

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<dynamic> getProjects() async {
    String token = await getToken();

    int locations = widget.location!['id'];

    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/contract/location/$locations'),
        headers: {"Authorization": "Token $token"});

    var resBody = json.decode(utf8.decode(res.bodyBytes));
    print('project');
    print(locations);
    print('ubicaciones');
    print(resBody);

    setState(() {
      listProjects = resBody;
      rows = resBody;
      if (listProjects.isNotEmpty) {
        isData = 'Y';
      } else {
        isData = 'N';
      }
    });

    return "Sucess";
  }

  Future<dynamic> getCrewSheets() async {
    String token = await getToken();
    int locations = widget.location!['id'];
    setState(() {});
    var res = await http.get(
        Uri.parse('${ApiWebServer.server_name}/api/v-1/crew/$locations/report'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);
    print('es crewsheet');
    print(resBody);

    setState(() {
      datar = resBody;
      if (datar.isNotEmpty) {
        isDataR = 'Y';
      } else {
        isDataR = 'N';
      }
    });
  }

  Future<dynamic> getWorkers() async {
    String token = await getToken();
    int locations = widget.location!['id'];
    setState(() {});
    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/crew/$locations/workers'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(utf8.decode(res.bodyBytes));
    print(resBody);

    setState(() {
      dataw = resBody;
      if (dataw.isNotEmpty) {
        isDataW = 'Y';
      } else {
        isDataW = 'N';
      }
    });
  }

  Future<dynamic> changeReport(id) async {
    setState(() {
      _isSending = true;
    });
    print('se fue');
    try {
      Provider.of<CrewProvider>(context, listen: false)
          .changeCrewReport(
        id,
      )
          .then((response) {
        setState(() {});
        print(response);
        if (response['estatus'] == '200') {
          _showSend();
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContractList(location: widget.location),
              ));
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
  }

  void _showInputDialog(String title, report) {
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
                              changeReport(report);
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

  void _showSending() {
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

  void _showSend() {
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

  void _showWorker(data) {
    // print(user.profile_image.toString().replaceAll('File: ', ''));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        // contentPadding: EdgeInsets.only(top: 5.0),
        content: Container(
          height: MediaQuery.of(context).size.height * 0.40,
          width: MediaQuery.of(context).size.width * 0.35,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('#' + data['btn_id'],
                      style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: HexColor('EA6012'))),
                  Text(data['last_name'] + ' ' + data['first_name'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: HexColor('EA6012'))),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Column(
                  children: <Widget>[
                    /*SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),*/
                    Container(
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/cargando.gif',
                        image: data['profile_image']
                            .toString()
                            .replaceAll('File: ', '')
                            .replaceAll("'", ""),
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.height * 0.35,
                      ) /*Image.network(user.profile_image
                          .toString()
                          .replaceAll('File: ', '')
                          .replaceAll("'", ""))*/
                      ,
                    )
                  ],
                ),
              ),
              /* InkWell(
                child: Container(
                  padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                  decoration: BoxDecoration(
                    //color: myColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32.0),
                        bottomRight: Radius.circular(32.0)),
                  ),
                  child: FlatButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'Ok',
                      style: TextStyle(
                          color: HexColor('EA6012'),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getProjects();
    getCrewSheets();
    getWorkers();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    print(widget.location);
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          body: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
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
                            //Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProjectListN()));
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
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(HexColor('EA6012')),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InitCrewReport(
                                        contract: widget.location,
                                      )),
                            );
                          },
                          child: const Text(
                            'Crew Sheet +',
                            style: TextStyle(
                                // fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Row(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(left: 20),
                    child: Text('${l10n.project}: '),
                  ),
                ],
              ),
              Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      widget.location != null
                          ? widget.location!['project_name']
                          : '---',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: HexColor('3E3E3E')),
                    ),
                  )),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(left: 20),
                child: Text('${l10n.offer_location}: '),
              ),
              Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      widget.location != null
                          ? widget.location!['name']
                          : '---',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: HexColor('EA6012')),
                    ),
                  )),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(left: 20),
                child: Text(l10n.address_o + ': '),
              ),
              Container(
                  alignment: Alignment.topLeft,
                  //width: MediaQuery.of(context).size.width * 0.90,
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      widget.location!['verified_address'] ?? '-',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: HexColor('3E3E3E')),
                    ),
                  )),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              if (_isSending) ...[
                Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        '${l10n.sending}...',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: HexColor('EA6012')),
                      ),
                    )),
              ],
              Container(
                color: Colors.white, // Tab Bar color change
                child: TabBar(
                  // TabBar
                  unselectedLabelColor: Colors.grey,
                  labelColor: Colors.black,
                  indicatorWeight: 3,
                  indicatorColor: HexColor('EA6012'),
                  labelStyle:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(
                      text: 'Crew Sheets',
                    ),
                    Tab(
                      text: '${l10n.workers} ${dataw.length}',
                    ),
                    Tab(
                      text: l10n.contracts,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: TabBarView(
                  // Tab Bar View
                  physics: BouncingScrollPhysics(),
                  children: <Widget>[
                    isDataR == ''
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : isDataR == 'Y'
                            ? Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.65,
                                child: MediaQuery.removePadding(
                                    removeTop: true,
                                    context: context,
                                    child: ListView.builder(
                                        itemCount: datar.length,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              print(datar[index]);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailCrewsheet(
                                                            project:
                                                                datar[index],
                                                            report: datar[index]
                                                                ['id'])),
                                              );
                                            },
                                            child: Column(
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Card(
                                                    margin: EdgeInsets.only(
                                                        left: 20, right: 20),
                                                    color: Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            side: BorderSide(
                                                                color: HexColor(
                                                                    'EA6012'),
                                                                width: 1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0)),
                                                    child: Column(
                                                      children: <Widget>[
                                                        SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.01,
                                                        ),
                                                        Row(
                                                          children: <Widget>[
                                                            Expanded(
                                                                flex: 2,
                                                                child:
                                                                    Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.67,
                                                                  child: Column(
                                                                    children: <Widget>[
                                                                      Row(
                                                                        children: [
                                                                          Container(
                                                                            margin:
                                                                                EdgeInsets.only(left: 15),
                                                                            child:
                                                                                Text('ID# ', style: TextStyle(fontSize: 14, color: HexColor('3E3E3E'), fontWeight: FontWeight.bold)),
                                                                          ),
                                                                          Container(
                                                                            child:
                                                                                Text(datar[index]['id'].toString()),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Container(
                                                                            margin:
                                                                                EdgeInsets.only(left: 15),
                                                                            child:
                                                                                Text(l10n.date + ': ', style: TextStyle(fontSize: 14, color: HexColor('3E3E3E'), fontWeight: FontWeight.bold)),
                                                                          ),
                                                                          Container(
                                                                            child:
                                                                                Text(DateFormat("MMMM d yyyy").format(DateTime.parse(datar[index]['workday_entry_time'])), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: HexColor('EA6012'))),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Container(
                                                                            margin:
                                                                                EdgeInsets.only(left: 15),
                                                                            child:
                                                                                Text(l10n.workers + ': ', style: TextStyle(fontSize: 14, color: HexColor('3E3E3E'), fontWeight: FontWeight.bold)),
                                                                          ),
                                                                          Container(
                                                                            child:
                                                                                Text(datar[index]['workers_count'].toString()),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Container(
                                                                            margin:
                                                                                EdgeInsets.only(left: 15),
                                                                            child: Text(
                                                                                datar[index]['status'].toString() == '1'
                                                                                    ? l10n.wr_21
                                                                                    : datar[index]['status'].toString() == '2'
                                                                                        ? l10n.wr_22
                                                                                        : datar[index]['status'].toString() == '3'
                                                                                            ? l10n.wr_222
                                                                                            : l10n.rejected,
                                                                                style: TextStyle(
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 13,
                                                                                    color: datar[index]['status'].toString() == '1'
                                                                                        ? HexColor('EA6012')
                                                                                        : datar[index]['status'].toString() == '2'
                                                                                            ? Colors.blue
                                                                                            : datar[index]['status'].toString() == '3'
                                                                                                ? Colors.green
                                                                                                : Colors.red)),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )),
                                                            Expanded(
                                                                flex: 1,
                                                                child:
                                                                    Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .topCenter,
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.33,
                                                                  child: Column(
                                                                    children: <Widget>[
                                                                      Text(
                                                                          l10n
                                                                              .hours,
                                                                          style: TextStyle(
                                                                              fontSize: 14,
                                                                              color: HexColor('3E3E3E'))),
                                                                      Text(
                                                                          datar[index]['worked_hours']
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 30,
                                                                              color: HexColor('EA6012'))),
                                                                      Text('',
                                                                          style: TextStyle(
                                                                              fontSize: 11,
                                                                              color: HexColor('3E3E3E')))
                                                                    ],
                                                                  ),
                                                                )),
                                                          ],
                                                        ),
                                                        /*  SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.01,
                                                        ),*/
                                                        Row(
                                                          children: <Widget>[
                                                            Expanded(
                                                              flex: 1,
                                                              child: Container(
                                                                color: HexColor(
                                                                    'F1F1F2'),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.1,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.33,
                                                                child:
                                                                    TextButton(
                                                                        child: Text(
                                                                            l10n
                                                                                .wr_17,
                                                                            style: TextStyle(
                                                                                fontSize: 16,
                                                                                color: HexColor('EA6012'),
                                                                                fontWeight: FontWeight.bold)),
                                                                        onPressed: () {
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                                builder: (context) => EditCrewReport1(
                                                                                      project: widget.location,
                                                                                      report: datar[index],
                                                                                    )),
                                                                          );
                                                                        }),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: Container(
                                                                color: HexColor(
                                                                    'F1F1F2'),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.1,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.33,
                                                                child:
                                                                    TextButton(
                                                                  child: Text(
                                                                      l10n
                                                                          .wr_18,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          color: HexColor(
                                                                              'EA6012'),
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => DetailCrewsheet(
                                                                              project: datar[index],
                                                                              report: datar[index]['id'])),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: Container(
                                                                color: HexColor(
                                                                    'F1F1F2'),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.1,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.33,
                                                                child:
                                                                    TextButton(
                                                                  child: Text(
                                                                      l10n
                                                                          .submit,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          color: datar[index]['status'].toString() == '1'
                                                                              ? HexColor('EA6012')
                                                                              : Colors.grey,
                                                                          fontWeight: FontWeight.bold)),
                                                                  onPressed:
                                                                      () {
                                                                    if (datar[index]['status']
                                                                            .toString() ==
                                                                        '1') {
                                                                      _showInputDialog(
                                                                          l10n
                                                                              .infor_re,
                                                                          datar[index]
                                                                              [
                                                                              'id']);
                                                                    }
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    )),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01,
                                                ),
                                              ],
                                            ),
                                          );
                                        })),
                              )
                            : Center(
                                child: Text(l10n.no_register),
                              ),

                    // ignore: unrelated_type_equality_checks

                    Container(
                      height: MediaQuery.of(context).size.height * 0.65,
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child:
                          /*MediaQuery.removePadding(
                          removeTop: true,
                          context: context,
                          child: ListView.builder(
                              itemCount: dataw.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _showWorker(dataw[index]);
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(left: 5),
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 5),
                                            child: Text(
                                              'ID#' +
                                                  ' ' +
                                                  '${dataw[index]['btn_id']}',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Container(
                                            child: Text(
                                              '${dataw[index]['last_name']}' +
                                                  ' ' +
                                                  '${dataw[index]['first_name']}',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }))*/
                          //Text('Data')
                          Text('ListWorkersGeneral'),
                      //ListWorkersGeneral(contract: widget.location),
                    ),

                    Container(
                      height: MediaQuery.of(context).size.height * 0.65,
                      child: MediaQuery.removePadding(
                          removeTop: true,
                          context: context,
                          child: ListView.builder(
                              itemCount: rows.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DetailProject(
                                                project: rows[index],
                                              )),
                                    );
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Card(
                                          margin: EdgeInsets.only(
                                              left: 20, right: 20),
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: HexColor('EA6012'),
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      margin: EdgeInsets.only(
                                                          left: 10),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.80,
                                                      child: Column(
                                                        children: <Widget>[
                                                          SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.02,
                                                          ),
                                                          Container(
                                                              child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                              rows[index][
                                                                  'contract_name'],
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                  color: HexColor(
                                                                      '3E3E3E')),
                                                            ),
                                                          )),
                                                          Container(
                                                              child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                              rows[index]
                                                                  ['customer'],
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                  color: HexColor(
                                                                      'EA6012')),
                                                            ),
                                                          )),
                                                          Container(
                                                              child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                              rows[index]['current_workday_status'] ==
                                                                      'CIS'
                                                                  ? l10n
                                                                      .clockin_started
                                                                  : rows[index][
                                                                              'current_workday_status'] ==
                                                                          'CIE'
                                                                      ? l10n
                                                                          .clockin_finish
                                                                      : rows[index]['current_workday_status'] ==
                                                                              'COS'
                                                                          ? l10n
                                                                              .clockout_started
                                                                          : rows[index]['current_workday_status'] == 'C0E'
                                                                              ? l10n.clockout_finish
                                                                              : rows[index]['current_workday_status'] == 'WRE'
                                                                                  ? l10n.complete_report
                                                                                  : l10n.to_init_day,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .green,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          )),
                                                          SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.02,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        alignment:
                                                            Alignment.topRight,
                                                        // margin: EdgeInsets.only(left: 5),
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.10,
                                                        child: Row(
                                                          children: <Widget>[
                                                            Container(
                                                              child: Column(
                                                                children: <Widget>[
                                                                  Container(
                                                                      child:
                                                                          Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topLeft,
                                                                    child: Text(
                                                                      rows[index]
                                                                              [
                                                                              'number_of_workers']
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              35,
                                                                          color:
                                                                              HexColor('EA6012')),
                                                                    ),
                                                                  )),
                                                                  Container(
                                                                      child:
                                                                          Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topLeft,
                                                                    child: Text(
                                                                      '${l10n.workers}\n${l10n.clockout_11}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              HexColor('3E3E3E')),
                                                                    ),
                                                                  ))
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ))
                                                ],
                                              ),
                                            ],
                                          )),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.01,
                                      ),
                                    ],
                                  ),
                                );
                              })),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
