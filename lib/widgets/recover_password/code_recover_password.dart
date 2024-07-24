import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../providers/auth.dart';
import 'recover_finish_password.dart';

class CodeRecover extends StatefulWidget {
  final String email;

  const CodeRecover({required this.email});

  @override
  _CodeRecoverState createState() => _CodeRecoverState(email);
}

class _CodeRecoverState extends State<CodeRecover> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  late String _code;
  late String email;
  _CodeRecoverState(this.email);

  var _isLoading = false;

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
            child: Text(
              'Ok',
              style: TextStyle(color: HexColor('EA6012')),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<dynamic> _submit() async {
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
          .verifyCode(_code)
          .then((response) {
        final l10n = AppLocalizations.of(context)!;

        setState(() {
          _isLoading = false;
        });

        if (response == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RecoverFinishPassword()),
          );
        } else {
          var errorMessage = 'Authentication failed';
          errorMessage = l10n.verif_code;
          _showErrorDialog(errorMessage);
        }
        /* var errorMessage = 'Authentication failed';
        errorMessage = 'Por favor verifique el Código.';
        _showErrorDialog(errorMessage);*/
      });
    } catch (error) {}

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String _titleH = l10n.send_code;

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
                        child: Text(l10n.code,
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
                          Text(l10n.code1,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                  color: HexColor('EA6012'))
                              // style: heading35Black,
                              ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          Text(l10n.code2,
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
                                  keyboardType: TextInputType.number,
                                  // ignore: missing_return
                                  onSaved: (value) {
                                    _code = value!;
                                  },
                                  onChanged: (value) {
                                    _code = value;
                                  },
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
                                      hintText: l10n.code,
                                      hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontFamily: 'Quicksand'))),
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
                                          if (_code != null) {
                                            _submit();
                                          } else {
                                            _showErrorDialog(l10n.verif_code);
                                          }
                                        },

                                        child: Text(
                                          l10n.validate,
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
    ));
  }
}
