import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

import '../../providers/auth.dart';
import '../login/login_new.dart';

class RecoverFinishPassword extends StatefulWidget {
  @override
  _RecoverFinishPasswordState createState() => _RecoverFinishPasswordState();
}

class _RecoverFinishPasswordState extends State<RecoverFinishPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  Map<String, String> _authData = {
    'passwd1': '',
    'passwd2': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Auth>(context, listen: false)
          .changePassword(_authData['passwd1'], _authData['passwd2'])
          .then((_) {
        final l10n = AppLocalizations.of(context)!;

        setState(() {
          _isLoading = false;
        });
        var errorMessage = 'Authentication failed';
        errorMessage = l10n.please_verif;
        _showErrorDialog(errorMessage);
      });
    } catch (error) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginNew()),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String _titleH = 'Recuperar Clave';

    return Scaffold(
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
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 20.0),
                        alignment: Alignment.topLeft,
                        child: Text(l10n.new_pass,
                            style: TextStyle(
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
                            height: MediaQuery.of(context).size.height * 0.06,
                          ),
                          Text(l10n.new_pass1,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                  color: HexColor('EA6012'))
                              // style: heading35Black,
                              ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          Text(l10n.new_pass2,
                              style: TextStyle(
                                  //fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.grey)
                              // style: heading35Black,
                              ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.09,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              TextFormField(
                                keyboardType: TextInputType.text,
                                obscureText: true,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    prefixIcon: Icon(Icons.lock,
                                        color: HexColor('EA6012'), size: 20.0),
                                    contentPadding:
                                        EdgeInsets.only(left: 15.0, top: 15.0),
                                    hintText: l10n.key_password,
                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: 'Quicksand')),
                                onSaved: (value) {
                                  _authData['passwd1'] = value!;
                                },
                                onChanged: (value) {
                                  _authData['passwd1'] = value;
                                },
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                              TextFormField(
                                keyboardType: TextInputType.text,
                                obscureText: true,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    prefixIcon: Icon(Icons.lock,
                                        color: HexColor('EA6012'), size: 20.0),
                                    contentPadding:
                                        EdgeInsets.only(left: 15.0, top: 15.0),
                                    hintText: l10n.confirm_password,
                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: 'Quicksand')),
                                onSaved: (value) {
                                  _authData['passwd2'] = value!;
                                },
                                onChanged: (value) {
                                  _authData['passwd2'] = value;
                                },
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 1.0),
                                width: double.infinity,
                                child: _isLoading
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : ElevatedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                              width: 5.0,
                                              color: HexColor('EA6012')),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0)),
                                        ), //borderSide: BorderSide(color: HexColor('EA6012')),
                                        //onPressed: () => select("English"),
                                        onPressed: () {
                                          if (_authData['passwd1'] == null) {
                                            _showErrorDialog(
                                                l10n.password_short);
                                          } else if (_authData['passwd2'] ==
                                              null) {
                                            _showErrorDialog(
                                                l10n.confirm_password);
                                          } else if (_authData['passwd1'] !=
                                              _authData['passwd2']) {
                                            _showErrorDialog(
                                                l10n.password_verify);
                                          } else {
                                            _submit();
                                          }
                                        },

                                        child: Text(
                                          l10n.update_next,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: Colors.white),
                                        ),
                                      ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01,
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
    )
        /*Container(
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
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Container(
                  //margin: EdgeInsets.only(top: 10.0),
                  child: Image.asset(
                    "assets/nuevo-naranja.png",
                    width: MediaQuery.of(context).size.width * 0.60,
                    //height: 220,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.06,
                ),
                Text(
                  _titleH,
                  style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                          //fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: HexColor('EA6012'))),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.08,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.only(left: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.05,
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.only(left: 20),
                            child: Image.asset(
                              'assets/clave.png',
                              color: Colors.black,
                              width: 30,
                            ),
                          ),
                        )),
                    Expanded(
                        flex: 4,
                        child: Container(
                          margin: EdgeInsets.only(right: 20, left: 10),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.95,
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.only(right: 20),
                            child: TextFormField(
                              obscureText: true,
                              decoration: InputDecoration(
                                  labelText: AppTranslations.of(context)
                                      .text("new_password"),
                                  labelStyle: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                          //fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black))),
                              keyboardType: TextInputType.emailAddress,
                              // ignore: missing_return
                              validator: (value) {
                                if (value.isEmpty || value.length < 8) {
                                  return 'Invalid Password!';
                                }
                              },
                              onSaved: (value) {
                                _authData['passwd1'] = value;
                              },
                            ),
                          ),
                        )),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.only(left: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.05,
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.only(left: 20),
                            child: Image.asset(
                              'assets/clave.png',
                              color: Colors.black,
                              width: 30,
                            ),
                          ),
                        )),
                    Expanded(
                        flex: 4,
                        child: Container(
                          margin: EdgeInsets.only(right: 20, left: 10),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.95,
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.only(right: 20),
                            child: TextFormField(
                              obscureText: true,
                              decoration: InputDecoration(
                                  labelText: AppTranslations.of(context)
                                      .text("confirm_password"),
                                  labelStyle: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                          //fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black))),
                              keyboardType: TextInputType.text,
                              // ignore: missing_return
                              validator: (value) {
                                if (value.isEmpty || value.length < 8) {
                                  return 'Password debe coincidir!';
                                }
                              },
                              onSaved: (value) {
                                _authData['passwd2'] = value;
                              },
                            ),
                          ),
                        )),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                ),
                Container(
                  margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  padding: EdgeInsets.symmetric(vertical: 1.0),
                  width: double.infinity,
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : OutlineButton.icon(
                          borderSide: BorderSide(color: HexColor('EA6012')),
                          //onPressed: () => select("English"),
                          onPressed: _submit,
                          padding: EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          icon: ImageIcon(
                            AssetImage('assets/enviar.png'),
                            color: HexColor('EA6012'),
                            size: 30,
                          ),
                          label: Text(
                            AppTranslations.of(context).text("submit"),
                            style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: HexColor('EA6012'))),
                          ),
                          color: Colors.white,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),*/

        );
  }
}

class TextOptionChangeP extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 25.0),
      margin: EdgeInsets.only(left: 60.0, right: 60.0),
      width: double.infinity,
      child: Text('Para continuar debes ingresar una nueva clave.',
          style: TextStyle(
              fontFamily: 'OpenSans',
              color: HexColor('233062'),
              fontSize: 15.0,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
    );
  }
}
