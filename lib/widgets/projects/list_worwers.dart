import 'dart:convert';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/model/expenses.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'dart:io';
import '../../model/user.dart';
import '../../model/expenses.dart';
import 'package:http/http.dart' as http;
import '../global.dart';
import '../widgets.dart';

class ListWorkersProject extends StatefulWidget {
  static const routeName = '/new-expenses';
  final User? user;
  int? contract;
  Map<String, dynamic>? project;

  ListWorkersProject({this.user, this.contract, this.project});

  @override
  _ListWorkersProjectsState createState() =>
      _ListWorkersProjectsState(user, contract, project);
}

class _ListWorkersProjectsState extends State<ListWorkersProject> {
  User? user;
  int? contract;
  Map<String, dynamic>? project;

  _ListWorkersProjectsState(this.user, this.contract, this.project);
  GlobalKey<_ListWorkersProjectsState> signatureKey = GlobalKey();
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.blue,
  );

  var maskTextInputFormatter = MaskTextInputFormatter(
      mask: "+1(###)#######", filter: {"#": RegExp(r'[0-9]')});

  String? success;
  bool signa = false;
  File? image;

  double? maxtop;
  double? maxwidth;
  List? listType = [];

  // ignore: unused_field
  File? _storedImageC;
  var _isLoading = false;
  String? blood;
  String? qrCodeResult;

  final _priceFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  final _form1 = GlobalKey<FormState>();
  int? selectedRadio;
  int? selectedRadio1;
  int? selectedRadio2;
  String? brand;
  var selectedValue;
  var rows = [];
  List results = [];
  String? query = '';
  TextEditingController? tc;

  // ignore: unused_field
  String? _myActivityResult;

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<dynamic> getWorkers() async {
    String token = await getToken();
    int? contract = widget.contract;

    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/contract/$contract/list-workers-accepted'),
        headers: {"Authorization": "Token $token"});

    var resBody = json.decode(utf8.decode(res.bodyBytes));

    setState(() {
      rows = resBody;
    });

    print(resBody);

    return "Sucess";
  }

  setSelectedRadio1(int val) {
    setState(() {
      selectedRadio1 = val;
    });
  }

  void _showWorker(data) {
    //print(user.profile_image.toString().replaceAll('File: ', ''));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        contentPadding: EdgeInsets.only(top: 10.0),
        content: Container(
          height: 420,
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    data['first_name'] + '\n' + data['last_name'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: HexColor('EA6012')),
                  ),
                ],
              ),
              SizedBox(
                height: 4.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Emplooy ID#' ' ' + data['btn_id'],
                    style: TextStyle(
                        //fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 30.0, right: 30.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Container(
                      child: FadeInImage.assetNetwork(
                        width: 250,
                        height: 250,
                        placeholder: 'assets/cargando.gif',
                        image: data['profile_image']
                            .toString()
                            .replaceAll('File: ', '')
                            .replaceAll("'", ""),
                      ) /*Image.network(user.profile_image
                          .toString()
                          .replaceAll('File: ', '')
                          .replaceAll("'", ""))*/
                      ,
                    )
                  ],
                ),
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  decoration: BoxDecoration(
                    //color: myColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32.0),
                        bottomRight: Radius.circular(32.0)),
                  ),
                  child: TextButton(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getWorkers();
    selectedRadio = 0;
    selectedRadio1 = 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (listType != null) {
      print(listType);
    }

    DateFormat format = DateFormat("yyyy-MM-dd");
    return Scaffold(
      body: Form(
        key: _form,
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
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
                    widget.project != null
                        ? widget.project!['customer']
                        : '---',
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
                        ? widget.project!['first_address']
                        : '---',
                    style: TextStyle(
                      //fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(l10n.workers,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: HexColor('EA6012'))),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              //padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: tc,
                decoration: InputDecoration(hintText: 'Buscar.'),
                onChanged: (v) {
                  setState(() {
                    query = v;
                    setResults(query!);
                  });
                },
              ),
            ),
            Container(
                margin: EdgeInsets.only(top: 10, left: 10),
                child: MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: query!.isEmpty
                        ? ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: rows.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      _showWorker(rows[index]);
                                      /*  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ConfirmWorkerWarnings(
                                                    user: this.widget.user,
                                                    contract:
                                                        this.widget.contract,
                                                    worker: rows[index],
                                                  )),
                                        );*/
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          //flex: 1,
                                          child: Container(
                                            alignment: Alignment.topLeft,
                                            margin: EdgeInsets.only(left: 10),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.01,
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            alignment: Alignment.topLeft,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.25,
                                            // margin: EdgeInsets.only(left: 5),
                                            child: Text(
                                              'ID#' +
                                                  ' ' +
                                                  '${rows[index]['btn_id']}',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: Container(
                                            alignment: Alignment.topLeft,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.75,
                                            //margin: EdgeInsets.only(left: 5),
                                            child: Text(
                                              '${rows[index]['last_name']},' +
                                                  ' ' +
                                                  '${rows[index]['first_name']}',
                                              style: TextStyle(fontSize: 15),
                                            ),
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
                            },
                          )
                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      _showWorker(results[index]);
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          //flex: 1,
                                          child: Container(
                                            alignment: Alignment.topLeft,
                                            margin: EdgeInsets.only(left: 10),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.01,
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            alignment: Alignment.topLeft,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.19,
                                            // margin: EdgeInsets.only(left: 5),
                                            child: Text(
                                              'ID#' +
                                                  ' ' +
                                                  '${results[index]['btn_id']}',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: Container(
                                            alignment: Alignment.topLeft,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.80,
                                            //margin: EdgeInsets.only(left: 5),
                                            child: Text(
                                              '${results[index]['last_name']},' +
                                                  ' ' +
                                                  '${results[index]['first_name']}',
                                              style: TextStyle(fontSize: 15),
                                            ),
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
                            },
                          ))),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
          ],
        ),
      ),
    );
  }

  void setResults(String query) {
    results = rows
        .where((elem) =>
            elem['first_name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            elem['btn_id']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();
  }
}
