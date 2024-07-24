import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

import '../../recover_password/code_recover_password.dart';
import '../../widgets.dart';
import '../../../providers/auth.dart';
import 'confirm.dart';

class InfoDelete extends StatefulWidget {
  @override
  _InfoDeleteState createState() => _InfoDeleteState();
}

class _InfoDeleteState extends State<InfoDelete> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  late String _email = '';
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
    print('llego');

    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Auth>(context, listen: false)
          .verifyEmail(_email.toLowerCase())
          .then((_) {
        setState(() {
          _isLoading = false;
        });
        var errorMessage = 'Authentication failed';
        errorMessage = 'Por favor verifique el Email.';
        _showErrorDialog(errorMessage);
      });
    } catch (error) {
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
                          child: Text(l10n.delete_a,
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
                            Text(l10n.import,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                    color: HexColor('EA6012'))
                                // style: heading35Black,
                                ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            Text(l10n.info_d,
                                style: TextStyle(
                                    //fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.grey)
                                // style: heading35Black,
                                ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Text(l10n.info_d1,
                                style: TextStyle(
                                    //fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.grey)
                                // style: heading35Black,
                                ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Text(l10n.info_d2,
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
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.18,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 1.0),
                                  width: double.infinity,
                                  child: _isLoading
                                      ? Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : ElevatedButton(
                                          //borderSide: BorderSide(color: HexColor('EA6012')),
                                          //onPressed: () => select("English"),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ConfirmDelete()));
                                          },

                                          child: Text(
                                            l10n.process_d,
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
      ), /* Container(
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
                              'assets/mail.png',
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
                              decoration: InputDecoration(
                                  labelText: AppTranslations.of(context)
                                      .text("key_email"),
                                  labelStyle: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                          //fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black))),
                              keyboardType: TextInputType.emailAddress,
                              // ignore: missing_return
                              validator: (value) {
                                if (value.isEmpty || !value.contains('@')) {
                                  return 'Invalid email!';
                                }
                              },
                              onSaved: (value) {
                                _email = value;
                              },
                            ),
                          ),
                        )),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.23,
                ),
                Container(
                  margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  padding: EdgeInsets.symmetric(vertical: 1.0),
                  width: double.infinity,
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : OutlineButton(
                          borderSide: BorderSide(color: HexColor('EA6012')),
                          //onPressed: () => select("English"),
                          onPressed: _submit,
                          padding: EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Text(
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
