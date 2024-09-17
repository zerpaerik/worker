import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/model/user.dart';
import 'package:worker/widgets/dashboard/index.dart';
import '../../../local/database_creator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:worker/model/config.dart';

import '../global.dart';
import '../login/login_new.dart';

class ConfirmProfile extends StatefulWidget {
  static const routeName = '/confirm-profile';

  ConfirmProfile();

  @override
  _ConfirmProfileState createState() => _ConfirmProfileState();
}

class _ConfirmProfileState extends State<ConfirmProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  _ConfirmProfileState();
  late String name = '';
  late String last = '';
  String birth_date = '';
  bool loading = false;
  List dataCountry = [];
  String country = '';
  String namec = '';
  String phone = '';
  var selectedValue;
  String gender = '';
  Map<String, dynamic>? _user;

  var now = DateTime.now();
  var formatterAno = DateFormat("y");

  var _isLoading = false;
  late Config? config;
  DateTime? hourClock; // init workday

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<dynamic> logout() async {
    String token = await getToken();

    setState(() {
      loading = true;
    });
    var res = await http.post(
        Uri.parse(ApiWebServer.server_name + '/api/v-1/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token $token'
        });

    if (res.statusCode == 200) {
      setState(() {
        loading = false;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs?.setBool("isLoggedIn", false);
      SharedPreferences prefrences = await SharedPreferences.getInstance();
      await prefrences.clear();

      // ignore: use_build_context_synchronously
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginNew()));
    } else {
      setState(() {
        loading = false;
      });
    }

    print(res.statusCode);
    print(res.body);
  }

  Future<dynamic> getSWData() async {
    var res = await http
        .get(Uri.parse('${ApiWebServer.server_name}/api/v-1/address/country'));
    var resBody = json.decode(res.body);

    setState(() {
      dataCountry = resBody;
      dataCountry
          .add({"id": 200, "name": "Prefer not to Answer", "code": "NONE"});
    });

    print(dataCountry);

    return "Sucess";
  }

  Future<dynamic> getWorker() async {
    String token = await getToken();

    var res = await http.get(
        Uri.parse('${ApiWebServer.server_name}/api/v-1/user/get_user_profile'),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "Authorization": "Token $token"
        });
    var resBody = json.decode(res.body);

    setState(() {
      _user = resBody;
    });

    print('worker');
    print(_user);

    return "Sucess";
  }

  Future<dynamic> _submit() async {
    String token = await getToken();
    DateFormat format = DateFormat("yyyy-MM-dd"); // FORMAT DATE

    print('llego aqui');
    setState(() {
      _isLoading = true;
    });

    int genderf;

    if (gender == 'Masculino' || gender == 'Man') {
      genderf = 1;
    } else {
      genderf = 2;
    }

    var res = await http.patch(Uri.parse(ApiWebServer.API_UPDATE_USER),
        body: json.encode({
          'birth_date': format.format(hourClock!),
          'gender': genderf,
          'phone_number': phone
        }),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "Authorization": "Token $token"
        });

    var resBody = json.decode(res.body);
    if (res.statusCode == 200) {
      setState(() {
        _isLoading = false;
      });
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DashboardHome(
                  noti: false,
                  data: {},
                )),
      );
    } else {
      //_showErrorDialog('Ha ocurrido un error');
      print(resBody);
    }
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

  @override
  void initState() {
    setState(() {
      gender = 'Man';
    });
    getTodo(1);
    getSWData();
    getWorker();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    DateFormat format = DateFormat("yyyy-MM-dd");

    return Scaffold(
        body: Form(
      key: _formKey,
      child: SingleChildScrollView(
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
                    margin: EdgeInsets.only(left: 15),
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
                          //_showOut();
                          //Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(right: 15),
                    width: MediaQuery.of(context).size.width * 0.50,
                    child: Container(
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: HexColor('EA6012'),
                        ),
                        onPressed: () {
                          // _showOut();

                          // Navigator.of(context).pop();
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
            Center(
                child: Container(
                    child: Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/aceptar-1.png',
                color: HexColor('EA6012'),
                width: 70,
              ),
            ))),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Container(
              margin: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                l10n.account_valid,
                style: TextStyle(
                    fontSize: 25,
                    color: HexColor('EA6012'),
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Container(
              margin: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                l10n.confirm,
                style: TextStyle(fontSize: 18, color: HexColor('EA6012')),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            if (config != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.39,
                    child: TextFormField(
                      initialValue: config != null ? config!.first_name : 'N/A',
                      decoration: InputDecoration(
                          focusColor: HexColor('EA6012'),
                          labelText: l10n.key_first_name,
                          labelStyle: TextStyle(
                            color: HexColor('EA6012'),
                            fontSize: 16,
                          )),
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Es obligatorio!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        /*_editedUser = User(
                          first_name: value != null ? value : config.first_name,
                          last_name: _editedUser.last_name,
                          birth_date: _editedUser.birth_date,
                        );*/
                      },
                      onChanged: (value) {
                        /* _editedUser = User(
                          first_name: value != null ? value : config.first_name,
                          last_name: _editedUser.last_name,
                          birth_date: _editedUser.birth_date,
                        );*/
                      },
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.39,
                    child: TextFormField(
                      initialValue: config != null ? config!.last_name : '',
                      decoration: InputDecoration(
                          focusColor: HexColor('EA6012'),
                          labelText: l10n.key_last_name,
                          labelStyle: TextStyle(
                            color: HexColor('EA6012'),
                            fontSize: 16,
                          )),
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      onSaved: (value) {},
                      onChanged: (value) {},
                    ),
                  ),
                ],
              )
            ],
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            Container(
              margin: EdgeInsets.only(top: 12, left: 30, right: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  l10n.birth_date,
                  style: TextStyle(color: HexColor('EA6012'), fontSize: 16),
                ),
              ),
            ),
            Container(
                //color: HexColor('009444'),
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(left: 30),
                //height: MediaQuery.of(context).size.width * 0.1,
                //width: MediaQuery.of(context).size.width * 0.40,
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Text(hourClock != null
                          ? hourClock.toString().substring(0, 11)
                          : '-'),
                    ),
                    SizedBox(
                      width: 35,
                      child: IconButton(
                        icon: Icon(Icons.calendar_today),
                        color: HexColor('EA6012'),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                              context: context,
                              firstDate: DateTime(1900),
                              initialDate: DateTime(
                                  int.parse(formatterAno.format(now)) - 18),
                              lastDate: DateTime(
                                  int.parse(formatterAno.format(now)) - 18));

                          setState(() {
                            hourClock = picked;
                          });

                          /*TimeOfDay? picketTime = await showDatePicker(
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

                            setState(() {
                              hourClock = selectedDateTime;
                            }); // You can use the selectedDateTime as needed.
                          }*/
                        },
                      ),
                    ),
                  ],
                )),
            Container(
              margin: EdgeInsets.only(top: 12, left: 30, right: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  l10n.gender,
                  style: TextStyle(color: HexColor('EA6012'), fontSize: 16),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: DropdownButton<String>(
                isExpanded: true,
                iconEnabledColor: HexColor('EA6012'),
                value: gender,
                hint: Text(
                  l10n.select,
                  style: TextStyle(fontSize: 16),
                ),
                items: <String>[l10n.man, l10n.woman].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    gender = value!;
                  });
                  print(gender);
                },
              ),
            ),
            Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: TextFormField(
                  decoration: InputDecoration(
                      focusColor: HexColor('EA6012'),
                      fillColor: HexColor('EA6012'),
                      hoverColor: HexColor('EA6012'),
                      labelText: l10n.phone,
                      labelStyle:
                          TextStyle(fontSize: 18, color: HexColor('EA6012'))),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Es obligatorio!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    setState(() {
                      phone = value!;
                    });
                  },
                  onChanged: (value) {
                    setState(() {
                      phone = value;
                    });
                  },
                )),
            SizedBox(height: MediaQuery.of(context).size.height * 0.10),
            Container(
              margin: EdgeInsets.only(left: 30.0, right: 30.0),
              padding: EdgeInsets.symmetric(vertical: 1.0),
              width: double.infinity,
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : OutlinedButton(
                      //onPressed: () => select("English"),
                      onPressed: () async {
                        if (hourClock == null ||
                            phone == null ||
                            gender == null) {
                          print('error');
                        } else {
                          _submit();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(width: 5.0, color: HexColor('EA6012')),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                      ),
                      child: Text(
                        l10n.update_next,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: HexColor('EA6012')),
                      ),
                    ),
            ),
          ],
        ),
      ),
    ));
  }
}
