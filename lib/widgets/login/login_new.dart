import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../providers/auth.dart';
import '../../model/http_exception.dart';
import '../dashboard/index.dart';
import '../recover_password/recover_password.dart';
import '../register/new_register.dart';

enum AuthMode { LoginNew }

class LoginNew extends StatefulWidget {
  static const routeName = '/auth';
  const LoginNew({
    Key? key,
  }) : super(key: key);

  @override
  _LoginNewState createState() => _LoginNewState();
}

class _LoginNewState extends State<LoginNew> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  // ignore: unused_field
  AuthMode _authMode = AuthMode.LoginNew;

  // ignore: unused_field
  late Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  var _authResponse;
  late String l;
  late String email = '';
  late String password = '';
  final _passwordController = TextEditingController();
  var maskTextInputFormatter =
      MaskTextInputFormatter(filter: {"": RegExp(r'[a-z, @]')});

  void _showErrorDialog(String message) {
    print(message);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        titleTextStyle: TextStyle(
            color: HexColor('373737'),
            fontFamily: 'OpenSansRegular',
            fontWeight: FontWeight.bold,
            fontSize: 20),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Ok',
              style: TextStyle(color: HexColor('EA6012')),
            ),
            //textColor: HexColor('EA6012'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    print('llego a submit login');
    setState(() {
      _isLoading = true;
    });
    print(email);
    print(password);
    await Provider.of<Auth>(context, listen: false)
        .login(
      email,
      password,
    )
        .then((response) {
      print('response vista');
      print(response);
      setState(() {
        _isLoading = false;
        _authResponse = response;
      });

      print('respuesta login');
      print(_authResponse);

      if (_authResponse['status'] == '200') {
        if (_authResponse['data']['role'] == 'business' ||
            _authResponse['data']['role'] == 'customer') {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardHome(
                  noti: false,
                  data: {},
                ),
              ));
        } else {
          /* FirebaseAuth.instance.signInWithEmailAndPassword(
              email: _authData['email'], password: _authData['email']);*/
          if (_authResponse['data']['has_profile_image'] == false) {
            print('aq');
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardHome(
                    noti: false,
                    data: {},
                  ),
                ));
            // Navigator.of(context).pushReplacementNamed('/confirm-profile');
            /*  Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ConfirmProfile()),
            );*/
          } else if (_authResponse['data']['id_type'] == null) {
            print('aq1');
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardHome(
                    noti: false,
                    data: {},
                  ),
                ));

            // Navigator.of(context).pushReplacementNamed('/confirm-profile');
            /*   Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TypeTax()),
            );*/
          } else if (_authResponse['data']['tax_doc_file'] ==
                  null /*||
            _authResponse['data']['id_type'] != '3' ||
            _authResponse['data']['id_type'] != '4' ||
            _authResponse['data']['id_type'] != '5'*/
              ) {
            print('aq4');
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardHome(
                    noti: false,
                    data: {},
                  ),
                ));
            if (_authResponse['data']['id_type'] == '1') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DashboardHome(
                      noti: false,
                      data: {},
                    ),
                  ));
              /* Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DocumentProfile(
                          document: 'SSN',
                        )),
              );*/
            } else if (_authResponse['data']['id_type'] == '2') {
              print('aq6');
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DashboardHome(
                      noti: false,
                      data: {},
                    ),
                  ));

              /*  Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DocumentProfile(
                          document: 'ITIN',
                        )),
              );*/
            } else {
              if (_authResponse['data']['legal_documents_count'] == null ||
                  _authResponse['data']['legal_documents_count'] == 0) {
                print('aq99');
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardHome(
                        noti: false,
                        data: {},
                      ),
                    ));

                // Navigator.of(context).pushReplacementNamed('/confirm-profile');
                /* Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TypeDocumentProfile()),
                );*/
              } else if (_authResponse['data']['has_city'] == false) {
                print('aq991');
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardHome(
                        noti: false,
                        data: {},
                      ),
                    ));

                // Navigator.of(context).pushReplacementNamed('/confirm-profile');
                /* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddressProfile()),
                );*/
              } else if (_authResponse['data']['blood_type'] == null) {
                print('aq992');
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardHome(
                        noti: false,
                        data: {},
                      ),
                    ));

                // Navigator.of(context).pushReplacementNamed('/confirm-profile');
                /* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HealthInformation()),
                );*/
              } else if (_authResponse['data']['contact_first_name'] == null) {
                print('aq993');
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardHome(
                        noti: false,
                        data: {},
                      ),
                    ));

                // Navigator.of(context).pushReplacementNamed('/confirm-profile');
                /* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactProfile()),
                );*/
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardHome(
                        noti: false,
                        data: {},
                      ),
                    ));
              }
            }
          } else if (_authResponse['data']['legal_documents_count'] == null ||
              _authResponse['data']['legal_documents_count'] == 0) {
            print('aq9994');
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardHome(
                    noti: false,
                    data: {},
                  ),
                ));

            // Navigator.of(context).pushReplacementNamed('/confirm-profile');
            /*Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TypeDocumentProfile()),
            );*/
          } else if (_authResponse['data']['has_city'] == false) {
            print('aq9996');
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardHome(
                    noti: false,
                    data: {},
                  ),
                ));

            // Navigator.of(context).pushReplacementNamed('/confirm-profile');
            /*   Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddressProfile()),
            );*/
          } else if (_authResponse['data']['blood_type'] == null) {
            print('aq9997');
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardHome(
                    noti: false,
                    data: {},
                  ),
                ));

            // Navigator.of(context).pushReplacementNamed('/confirm-profile');
            /*  Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HealthInformation()),
            );*/
          } else if (_authResponse['data']['contact_first_name'] == null) {
            print('aq9998');
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardHome(
                    noti: false,
                    data: {},
                  ),
                ));

            // Navigator.of(context).pushReplacementNamed('/confirm-profile');
            /* Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContactProfile()),
            );*/
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardHome(
                    noti: false,
                    data: {},
                  ),
                ));
          }
        }
      } else if (_authResponse['data'] != null) {
        switch (_authResponse['data'].toString()) {
          case "{non_field_errors: [This account is disabled. For more information communicate with btn staff]}":
            _showErrorDialog('Inactive');
            break;
          case "{non_field_errors: [Unable to log in with provided credentials]}":
            _showErrorDialog('Incorrect');
            break;
          case "{non_field_errors: [The account does not exists.]}":
            _showErrorDialog('Not found');
            break;
          default:
        }
      } else if (_authResponse['status'] == '400') {
        print('entro aqui sin sesion');
        _showErrorDialog('No active');
      } else {
        print('entro aqui otro error');
        switch (_authResponse['data'].toString()) {
          case "{non_field_errors: [This account is disabled. For more information communicate with btn staff]}":
            _showErrorDialog('No active');
            break;
          case "{non_field_errors: [Unable to log in with provided credentials]}":
            _showErrorDialog('Incorrect');
            break;
          case "{non_field_errors: [The account does not exists.]}":
            _showErrorDialog('Not found');
            break;
          default:
        }
      }
    });
    // var test = await Auth().login(email, password);
    //print('test');
    //print(test);
    /*   try {
      await Provider.of<Auth>(context, listen: false)
          .login(
        email,
        password,
      )
          .then((response) {
        print('response');
        print(response);
        setState(() {
          _isLoading = false;
          _authResponse = response;
        });
      });

      print('respuesta login');
      print(_authResponse);

      if (_authResponse['status'] == '200') {
        print('entro aquis');
        print(_authResponse);

        if (_authResponse['data']['role'] == 'business' ||
            _authResponse['data']['role'] == 'customer') {
          /*Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardHome(),
              ));*/
        } else {
          /* FirebaseAuth.instance.signInWithEmailAndPassword(
              email: _authData['email'], password: _authData['email']);*/
          if (_authResponse['data']['has_profile_image'] == false) {
            // Navigator.of(context).pushReplacementNamed('/confirm-profile');
            /*  Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ConfirmProfile()),
            );*/
          } else if (_authResponse['data']['id_type'] == null) {
            // Navigator.of(context).pushReplacementNamed('/confirm-profile');
            /*   Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TypeTax()),
            );*/
          } else if (_authResponse['data']['tax_doc_file'] ==
                  null /*||
            _authResponse['data']['id_type'] != '3' ||
            _authResponse['data']['id_type'] != '4' ||
            _authResponse['data']['id_type'] != '5'*/
              ) {
            print(_authResponse['data']['tax_doc_file']);
            if (_authResponse['data']['id_type'] == '1') {
              /* Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DocumentProfile(
                          document: 'SSN',
                        )),
              );*/
            } else if (_authResponse['data']['id_type'] == '2') {
              /*  Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DocumentProfile(
                          document: 'ITIN',
                        )),
              );*/
            } else {
              if (_authResponse['data']['legal_documents_count'] == null ||
                  _authResponse['data']['legal_documents_count'] == 0) {
                // Navigator.of(context).pushReplacementNamed('/confirm-profile');
                /* Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TypeDocumentProfile()),
                );*/
              } else if (_authResponse['data']['has_city'] == false) {
                // Navigator.of(context).pushReplacementNamed('/confirm-profile');
                /* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddressProfile()),
                );*/
              } else if (_authResponse['data']['blood_type'] == null) {
                // Navigator.of(context).pushReplacementNamed('/confirm-profile');
                /* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HealthInformation()),
                );*/
              } else if (_authResponse['data']['contact_first_name'] == null) {
                // Navigator.of(context).pushReplacementNamed('/confirm-profile');
                /* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactProfile()),
                );*/
              } else {
                /* Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardHome(),
                    ));*/
              }
            }
          } else if (_authResponse['data']['legal_documents_count'] == null ||
              _authResponse['data']['legal_documents_count'] == 0) {
            // Navigator.of(context).pushReplacementNamed('/confirm-profile');
            /*Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TypeDocumentProfile()),
            );*/
          } else if (_authResponse['data']['has_city'] == false) {
            // Navigator.of(context).pushReplacementNamed('/confirm-profile');
            /*   Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddressProfile()),
            );*/
          } else if (_authResponse['data']['blood_type'] == null) {
            // Navigator.of(context).pushReplacementNamed('/confirm-profile');
            /*  Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HealthInformation()),
            );*/
          } else if (_authResponse['data']['contact_first_name'] == null) {
            // Navigator.of(context).pushReplacementNamed('/confirm-profile');
            /* Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContactProfile()),
            );*/
          } else {
            /* Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardHome(),
                ));*/
          }
        }
      } else if (_authResponse['data'] != null) {
        switch (_authResponse['data'].toString()) {
          case "{non_field_errors: [This account is disabled. For more information communicate with btn staff]}":
            _showErrorDialog('Inactive');
            break;
          case "{non_field_errors: [Unable to log in with provided credentials]}":
            _showErrorDialog('Incorrect');
            break;
          case "{non_field_errors: [The account does not exists.]}":
            _showErrorDialog('Not found');
            break;
          default:
        }
      } else if (_authResponse['status'] == '400') {
        print('entro aqui sin sesion');
        _showErrorDialog('No active');
      } else {
        print('entro aqui otro error');
        switch (_authResponse['data'].toString()) {
          case "{non_field_errors: [This account is disabled. For more information communicate with btn staff]}":
            _showErrorDialog('No active');
            break;
          case "{non_field_errors: [Unable to log in with provided credentials]}":
            _showErrorDialog('Incorrect');
            break;
          case "{non_field_errors: [The account does not exists.]}":
            _showErrorDialog('Not found');
            break;
          default:
        }
      }
    } on HttpException catch (non_field_errors) {
      print('error');
      print(non_field_errors);
      var errorMessage = 'Authentication failed';
      if (non_field_errors
          .toString()
          .contains('Unable to log in with provided credentials.')) {
        errorMessage = 'Por favor verifique sus credenciales.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      print('entro aqui');
      print(error);
      //const errorMessage = 'Intentelo mas tarde!';
      //_showErrorDialog(errorMessage);
      //Navigator.of(context).pushReplacementNamed('/add-profile');
    }*/

    setState(() {
      //  _isLoading = false;
    });
  }

  getLang() async {
    SharedPreferences lang = await SharedPreferences.getInstance();
    String? stringValue = lang.getString('stringValue');
    l = stringValue!;
    return stringValue;
  }

  // ignore: unused_element

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String _titleH = l10n.welcome;

    return Scaffold(
      // backgroundColor: Colors.white,
      body: Container(
        // padding: EdgeInsets.all(5.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
              child: Stack(children: <Widget>[
            FittedBox(
                fit: BoxFit.contain,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.23,
                  width: /*double.infinity*/
                      MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: HexColor('EA6012'),
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
                            /* Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SelectLangUpdate()),
                                );*/
                            //Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 20.0),
                          alignment: Alignment.topLeft,
                          child: Text(l10n.login3,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 35,
                                  color: Colors.white)))
                    ],
                  ),
                )),
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
                          height: MediaQuery.of(context).size.height * 0.08,
                        ),
                        Text(l10n.welcome_back,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                                color: HexColor('EA6012'))
                            // style: heading35Black,
                            ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              autofillHints: [AutofillHints.email],
                              enableSuggestions: true,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  prefixIcon: Icon(Icons.email,
                                      color: HexColor('EA6012'), size: 20.0),
                                  contentPadding:
                                      EdgeInsets.only(left: 15.0, top: 15.0),
                                  hintText: 'Email',
                                  hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: 'Quicksand')),
                              onSaved: (value) {
                                setState(() {
                                  email = value!;
                                });
                                _authData['email'] = value!.toLowerCase();
                              },
                              onChanged: (value) {
                                setState(() {
                                  email = value;
                                });
                                _authData['email'] = value.toLowerCase();
                              },
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            TextFormField(
                              autofillHints: [AutofillHints.password],
                              enableSuggestions: true,
                              obscureText: true,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  prefixIcon: Icon(Icons.lock,
                                      color: HexColor('EA6012'), size: 20.0),
                                  contentPadding:
                                      EdgeInsets.only(left: 15.0, top: 15.0),
                                  hintText: 'Password',
                                  hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: 'Quicksand')),
                              onSaved: (value) {
                                setState(() {
                                  password = value!;
                                });
                                _authData['password'] = value!;
                              },
                              onChanged: (value) {
                                setState(() {
                                  password = value;
                                });
                                _authData['password'] = value;
                              },
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              alignment: Alignment.topRight,
                              //width: MediaQuery.of(context).size.width * 0.50,
                              child: TextButton(
                                  child: Text(l10n.label_recover_passwd,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: HexColor('EA6012'))),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RecoverPassword()),
                                    );
                                  }),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.10,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 1.0),
                              width: double.infinity,
                              child: _isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                HexColor('EA6012')),
                                      ),
                                      //color: HexColor('EA6012'),
                                      //borderSide: BorderSide(color: HexColor('EA6012')),
                                      //onPressed: () => select("English"),
                                      onPressed: () {
                                        if (_authData['email']!.isEmpty ||
                                            !_authData['email']!
                                                .contains('@')) {
                                          _showErrorDialog('Email invàlido');
                                        } else if (_authData['password']!
                                                .isEmpty ||
                                            _authData['password']!.isEmpty) {
                                          _showErrorDialog(
                                              'Debe ingresar una contraseña');
                                        } else {
                                          _submit();
                                        }
                                      },

                                      child: Text(
                                        l10n.login2,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                            color: Colors.white),
                                      ),
                                    ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            Container(
                                alignment: Alignment.topCenter,
                                child: Align(
                                    alignment: Alignment.center,
                                    child: Text(l10n.label_recover_account,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.grey)))),
                            Container(
                                child: SizedBox(
                                    height: 20,
                                    child: Align(
                                        alignment: Alignment.center,
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      RegisterUserNew()),
                                            );
                                          },
                                          child: Text(l10n.register1,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: HexColor('EA6012'))),
                                        ))))
                          ],
                        ),
                      ],
                    ),
                  )),
                ),
              ],
            )),
          ])),
        ),
      ),
    );
  }
}
