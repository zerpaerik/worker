import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:worker/local/database_creator.dart';
import 'package:worker/model/config.dart';
import 'package:worker/model/user.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../providers/auth.dart';
import '../dashboard/index.dart';

class ChangePasswordUser extends StatefulWidget {
  final User user;

  ChangePasswordUser({required this.user});
  @override
  _ChangePasswordUserState createState() => _ChangePasswordUserState(user);
}

class _ChangePasswordUserState extends State<ChangePasswordUser> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  User user;
  _ChangePasswordUserState(this.user);
  final GlobalKey<FormState> _formKey = GlobalKey();
  late Map<String, String> _authData = {
    'old': '',
    'passwd1': '',
    'passwd2': '',
  };
  late var _isLoading = false;
  late var confirmPass;
  late Config config;

  final _passwordController = TextEditingController();

  void _showErrorDialog(String message) {
    print(message);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error!'),
        content: Text(message),
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

  void _showviewRequest() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              child: Image.asset(
                'assets/aceptar-1.png',
                width: 110,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
                alignment: Alignment.center,
                child: Text('¡Su Contraseña ha sido Modificada con Exito!'))
          ],
        ),
        //Text('Tienes una nueva notificación!'),

        titleTextStyle: TextStyle(
          color: HexColor('373737'),
          fontFamily: 'OpenSansRegular',
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Ok',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: HexColor('EA6012'))),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<dynamic> _submit() async {
    int id = 9;

    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Auth>(context, listen: false)
          .changePasswordP(
              _authData['old'], _authData['passwd1'], _authData['passwd2'])
          .then((response) {
        setState(() {
          _isLoading = false;
        });
        if (response['status'] == '200') {
          _showviewRequest();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DashboardHome(
                      noti: false,
                      data: {},
                    )),
          );
        } else {
          _showErrorDialog(response['data']);
        }
      });
    } catch (error) {}

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getTodo(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String _titleH = l10n.change_password;

    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        //padding: EdgeInsets.all(12.0),
        child: Form(
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
                        margin: EdgeInsets.only(right: 15),
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
                //SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Image.asset(
                        'assets/padlock.png',
                        width: MediaQuery.of(context).size.width * 0.20,
                      )),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(left: 30.0),
                  child: Text(
                    _titleH,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: HexColor('EA6012')),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Container(
                  margin: EdgeInsets.only(left: 20.0, right: 20.0),
                  width: double.infinity,
                  child: TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.current_password,
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Colors.grey,
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    // ignore: missing_return
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Es Obligatorio!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['old'] = value!;
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20.0, right: 20.0),
                  width: double.infinity,
                  child: TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.new_password,
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Colors.grey,
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    // ignore: missing_return
                    validator: (value) {
                      confirmPass = value;
                      if (value!.isEmpty || value.length < 8) {
                        return 'Password es muy corto!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['passwd1'] = value!;
                    },
                  ),
                ),
                Container(
                  //padding: EdgeInsets.symmetric(vertical: 15.0),
                  margin: EdgeInsets.only(left: 20.0, right: 20.0),
                  width: double.infinity,
                  child: TextFormField(
                    obscureText: true,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: l10n.confirm_password,
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Colors.grey,
                      ),
                    ),
                    // ignore: missing_return
                    validator: (value) {
                      if (value != confirmPass) {
                        return 'Contraseñas no coinciden';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['passwd2'] = value!;
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.20),
                Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(right: 30),
                  //width: MediaQuery.of(context).size.width * 0.70,
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          onPressed: _submit,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(HexColor('EA6012')),
                          ),
                          child: Text(
                            l10n.submit,
                            style: TextStyle(
                                // fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white),
                          ),
                        ),
                ),
                /* Container(
                  margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 60.0),
                  width: double.infinity,
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : RaisedButton(
                          elevation: 5.0,
                          onPressed: _submit,
                          padding: EdgeInsets.all(17),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          color: HexColor('009444'),
                          child: Text(
                            AppTranslations.of(context).text("submit"),
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        ),
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}
