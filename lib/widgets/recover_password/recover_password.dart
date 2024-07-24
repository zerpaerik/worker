import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../providers/auth.dart';
import 'code_recover_password.dart';

class RecoverPassword extends StatefulWidget {
  @override
  _RecoverPasswordState createState() => _RecoverPasswordState();
}

class _RecoverPasswordState extends State<RecoverPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  late String _email = '';
  var _isLoading = false;

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

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });
    print('llegodsdsdsdsdsd');

    try {
      await Provider.of<Auth>(context, listen: false)
          .verifyEmail(_email.toLowerCase())
          .then((_) {
        final l10n = AppLocalizations.of(context)!;

        setState(() {
          _isLoading = false;
        });
        var errorMessage = 'Authentication failed';
        errorMessage = l10n.verif_email;
        _showErrorDialog(errorMessage);
      });
    } catch (error) {
      print('no hay error');
      print(error);
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CodeRecover(email: _email)),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                          child: Text(l10n.recoverp2,
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
                            Text(l10n.recoverp,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                    color: HexColor('EA6012'))
                                // style: heading35Black,
                                ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Text(l10n.recoverp1,
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
                                    keyboardType: TextInputType.emailAddress,
                                    // ignore: missing_return
                                    validator: (value) {
                                      if (value!.isEmpty ||
                                          !value.contains('@')) {
                                        return 'Invalid email!';
                                      }
                                    },
                                    onSaved: (value) {
                                      _email = value!;
                                    },
                                    onChanged: (value) {
                                      _email = value;
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
                                        hintText: l10n.key_email,
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
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    HexColor('EA6012')),
                                          ),
                                          //borderSide: BorderSide(color: HexColor('EA6012')),
                                          //onPressed: () => select("English"),
                                          onPressed: () {
                                            if (_email.isNotEmpty) {
                                              _submit();
                                            } else {
                                              _showErrorDialog(
                                                  l10n.email_oblig);
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
      ),
    );
  }
}
