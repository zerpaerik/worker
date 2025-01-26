import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/model/expenses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'dart:io';
import '../../model/user.dart';
import '../../model/expenses.dart';
import 'package:http/http.dart' as http;
import '../global.dart';
import '../widgets.dart';

class ListWorkersGeneral extends StatefulWidget {
  static const routeName = '/new-expenses';
  Map<String, dynamic>? contract;

  ListWorkersGeneral({this.contract});

  @override
  _ListWorkersGeneralState createState() => _ListWorkersGeneralState(contract!);
}

class _ListWorkersGeneralState extends State<ListWorkersGeneral> {
  Map<String, dynamic>? contract;

  _ListWorkersGeneralState(this.contract);
  GlobalKey<_ListWorkersGeneralState> signatureKey = GlobalKey();
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.blue,
  );

  var maskTextInputFormatter = MaskTextInputFormatter(
      mask: "+1(###)#######", filter: {"#": RegExp(r'[0-9]')});

  late String success;
  late bool signa = false;
  late File image;

  late double maxtop;
  late double maxwidth;
  late List listType = [];

  // ignore: unused_field
  late File _storedImageC;
  late String blood;
  late String qrCodeResult;

  late int selectedRadio;
  late int selectedRadio1;
  late int selectedRadio2;
  late String brand;
  var selectedValue;
  var rows = [];
  late List results = [];
  late String query = '';
  // final tc = TextEditingController();

  final TextEditingController tc = TextEditingController();

  // ignore: unused_field
  late String _myActivityResult;

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
    int locations = widget.contract!['id'];

    var res = await http.get(
        '${ApiWebServer.server_name}/api/v-1/crew/$locations/workers' as Uri,
        headers: {"Authorization": "Token $token"});

    var resBody = json.decode(utf8.decode(res.bodyBytes));

    setState(() {
      rows = resBody;
    });

    return "Sucess";
  }

  setSelectedRadio1(int val) {
    setState(() {
      selectedRadio1 = val;
    });
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

    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        Container(
          // margin: EdgeInsets.only(left: 20, right: 20),
          //padding: const EdgeInsets.all(10.0),
          child: TextField(
            controller: tc,
            decoration: InputDecoration(
                hintText: l10n.search, hintStyle: TextStyle(fontSize: 16)),
            onChanged: (v) {
              setState(() {
                query = v;
                setResults(query);
              });
            },
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Container(
            child: MediaQuery.removePadding(
                removeTop: true,
                context: context,
                child: query.isEmpty
                    ? ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: rows.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {},
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
                                        'ID# ${rows[index]['btn_id']}',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      child: Text(
                                        '${rows[index]['last_name']} ${rows[index]['first_name']}',
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
                                  onTap: () {},
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 5),
                                        child: Text(
                                          'ID# ${results[index]['btn_id']}',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        child: Text(
                                          '${results[index]['last_name']} ${results[index]['first_name']}',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  )),
                            ],
                          );
                        },
                      ))),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
      ],
    ));
  }

  void setResults(String query) {
    results = rows
        .where((elem) =>
            elem['first_name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            elem['last_name']
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
