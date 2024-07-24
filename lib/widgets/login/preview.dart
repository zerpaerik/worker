import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../register/new_register.dart';
import 'login_new.dart';

class PreviewAccount extends StatefulWidget {
  const PreviewAccount();

  @override
  State<PreviewAccount> createState() => _PreviewAccountState();
}

class _PreviewAccountState extends State<PreviewAccount> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/mobile_landing.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            Container(
              margin: EdgeInsets.only(left: 5.0),
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () {
                  /* Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SelectLangUpdate()),
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
              height: MediaQuery.of(context).size.height * 0.30,
            ),
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.10,
                //width: 10,
                child: Image.asset('assets/logo-blanco.png')),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.30,
            ),
            Container(
                margin: EdgeInsets.only(left: 30.0, right: 30),
                // padding: EdgeInsets.symmetric(vertical: 1.0),
                // width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(),
                  // color: Colors.white,
                  //borderSide: BorderSide(color: HexColor('EA6012')),
                  //onPressed: () => select("English"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginNew()),
                    );
                    // createTodo("Español");
                    // select("Español");
                  },

                  child: Text(
                    l10n.login3,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: HexColor('EA6012')),
                  ),
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Container(
              margin: EdgeInsets.only(left: 30.0, right: 30),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterUserNew()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(width: 5.0, color: HexColor('EA6012')),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
                child: Text(
                  l10n.register_user1,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
