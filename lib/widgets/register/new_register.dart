import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/users.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../register/confirmed.dart';
import 'package:worker/providers/url_constants.dart';

import '../../local/database_creator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:worker/model/config.dart';
import 'package:url_launcher/url_launcher.dart';
import '../global.dart';

class RegisterUserNew extends StatefulWidget {
  const RegisterUserNew({
    Key? key,
  }) : super(key: key);

  @override
  _RegisterUserNewState createState() => _RegisterUserNewState();
}

class _RegisterUserNewState extends State<RegisterUserNew> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  // ignore: unused_field
  // ignore: unused_field

  var _isLoading = false;
  late String name = '';
  late String lastname;
  late String email;
  late String password;
  late String password1;
  late Config config;
  late String phone;

  late String l;
  final _passwordController = TextEditingController();
  var maskTextInputFormatter =
      MaskTextInputFormatter(filter: {"": RegExp(r'[a-z, @]')});

  void _showErrorDialog(String message) {
    print(message);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
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

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<Users>(context, listen: false)
          .addUser(name, lastname, email, password, config.language)
          .then((response) {
        setState(() {
          _isLoading = false;
        });
        print(response['data']);
        if (response['status'] == '201') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ConfirmedRegister(email, response['data']['id'], 0)),
          );
        } else {
          switch (response['data'].toString()) {
            case "{email: [A user with that email address already exists.]}":
              _showErrorDialog('El email ya se encuentra registrado');
              break;
            default:
          }
        }
      });
    } catch (error) {}
  }

  getLang() async {
    SharedPreferences lang = await SharedPreferences.getInstance();
    String? stringValue = lang.getString('stringValue');
    l = stringValue!;
    return stringValue;
  }

  _launchURLTerms() async {
    const url = '${ApiWebServer.server_name}/terms-and-conditions';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchURLPolicy() async {
    const url = '${ApiWebServer.server_name}/privacy-policy';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    getTodo(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String _titleH = l10n.welcome;
    // ignore: deprecated_member_use
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: Container(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.23,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          //color: HexColor('EA6012'),
                          gradient: LinearGradient(
                            begin: Alignment.bottomRight,
                            end: Alignment.topLeft,
                            colors: [
                              HexColor('FBB03B'),
                              HexColor('EF6826'),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(25),
                              bottomRight: Radius.circular(25))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.06,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 5.0),
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 20.0),
                              alignment: Alignment.topLeft,
                              child: Text(l10n.register_user,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 35,
                                      color: Colors.white)))
                        ],
                      ),
                    ),
                    Container(
                        //height: MediaQuery.of(context).size.height,
                        //width: double.infinity,
                        child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 130.0),
                          child: Form(
                              //key: formKey,
                              child: Container(
                            padding: EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.06,
                                ),
                                Text(l10n.register_user1,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 26,
                                        color: Colors.grey)
                                    // style: heading35Black,
                                    ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.04,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    TextFormField(
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          prefixIcon: Icon(Icons.note,
                                              color: HexColor('EA6012'),
                                              size: 20.0),
                                          contentPadding: EdgeInsets.only(
                                              left: 15.0, top: 15.0),
                                          hintText: l10n.key_first_name,
                                          hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontFamily: 'Quicksand')),
                                      onChanged: (value) {
                                        name = value;
                                      },
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                    ),
                                    TextFormField(
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          prefixIcon: Icon(Icons.note,
                                              color: HexColor('EA6012'),
                                              size: 20.0),
                                          contentPadding: EdgeInsets.only(
                                              left: 15.0, top: 15.0),
                                          hintText: l10n.key_last_name,
                                          hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontFamily: 'Quicksand')),
                                      onChanged: (value) {
                                        lastname = value;
                                      },
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                    ),
                                    TextFormField(
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          prefixIcon: Icon(Icons.email,
                                              color: HexColor('EA6012'),
                                              size: 20.0),
                                          contentPadding: EdgeInsets.only(
                                              left: 15.0, top: 15.0),
                                          hintText: l10n.key_email,
                                          hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontFamily: 'Quicksand')),
                                      onChanged: (value) {
                                        email = value;
                                      },
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                    ),
                                    TextFormField(
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          prefixIcon: Icon(Icons.email,
                                              color: HexColor('EA6012'),
                                              size: 20.0),
                                          contentPadding: EdgeInsets.only(
                                              left: 15.0, top: 15.0),
                                          hintText: l10n.phone_number,
                                          hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontFamily: 'Quicksand')),
                                      onChanged: (value) {
                                        phone = value;
                                      },
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                    ),
                                    TextFormField(
                                      keyboardType: TextInputType.text,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          prefixIcon: Icon(Icons.lock,
                                              color: HexColor('EA6012'),
                                              size: 20.0),
                                          contentPadding: EdgeInsets.only(
                                              left: 15.0, top: 15.0),
                                          hintText: l10n.key_password,
                                          hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontFamily: 'Quicksand')),
                                      onChanged: (value) {
                                        password = value;
                                      },
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                    ),
                                    TextFormField(
                                      keyboardType: TextInputType.text,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          prefixIcon: Icon(Icons.lock,
                                              color: HexColor('EA6012'),
                                              size: 20.0),
                                          contentPadding: EdgeInsets.only(
                                              left: 15.0, top: 15.0),
                                          hintText: l10n.confirm_password,
                                          hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontFamily: 'Quicksand')),
                                      onChanged: (value) {
                                        password1 = value;
                                      },
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03,
                                    ),
                                    Container(
                                      child: Row(
                                        children: [
                                          Text(l10n.create,
                                              style: TextStyle(
                                                  //fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        InkWell(
                                            onTap: () {
                                              launch(
                                                  "$urlServices/terms-and-conditions");
                                            },
                                            child: Text(l10n.term_cond,
                                                style: TextStyle(
                                                    //fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: Colors.grey))),
                                        SizedBox(
                                          width: 2,
                                        ),
                                        Text(l10n.and,
                                            style: TextStyle(
                                                //fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Colors.grey)),
                                        SizedBox(
                                          width: 2,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              launch(
                                                  "$urlServices/privacy-policy");
                                            },
                                            child: Text(l10n.privacy,
                                                style: TextStyle(
                                                    //fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: Colors.grey))),
                                      ],
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 1.0),
                                      width: double.infinity,
                                      child: _isLoading
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        HexColor('EA6012')),
                                              ), //borderSide: BorderSide(color: HexColor('EA6012')),
                                              //onPressed: () => select("English"),
                                              onPressed: () {
                                                if (name.isEmpty) {
                                                  _showErrorDialog(
                                                      l10n.va_name);
                                                } else if (lastname.isEmpty) {
                                                  _showErrorDialog(l10n.va_ape);
                                                } else if (email.isEmpty ||
                                                    !email.contains('@')) {
                                                  _showErrorDialog(l10n.va_em);
                                                } else if (password.isEmpty) {
                                                  _showErrorDialog(l10n.va_p1);
                                                } else if (password.length <
                                                    8) {
                                                  _showErrorDialog(
                                                      l10n.password_short);
                                                } else if (password1.isEmpty) {
                                                  _showErrorDialog(l10n.va_p2);
                                                } else if (password !=
                                                    password1) {
                                                  _showErrorDialog(l10n.va_p3);
                                                } else {
                                                  _submit();
                                                }
                                              },

                                              child: Text(
                                                l10n.button_register,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                    color: Colors.white),
                                              ),
                                            ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                        ),
                      ],
                    )),
                  ])
                ],
              )),
            ),
          ),
        ));
  }
}
