import 'dart:io';
import 'dart:ui' as ui;
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:signature/signature.dart';
import 'package:worker/model/user.dart';

import '../../widgets.dart';
import '../../../providers/auth.dart';

class SignPostulation extends StatefulWidget {
  static const routeName = '/signa-profile';

  final User user;

  SignPostulation({required this.user});

  @override
  _SignPostulationState createState() => _SignPostulationState(user);
}

class _SignPostulationState extends State<SignPostulation> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();
  late User user;
  _SignPostulationState(this.user);

  late String _email;
  late File file;
  late String name;
  late String last;
  late String birth_date;
  late GlobalKey<_SignPostulationState> signatureKey = GlobalKey();
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.blue,
  );

  void _handleClearButtonPressed() {
    signatureGlobalKey.currentState?.clear();
  }

  void _handleSaveButtonPressed() async {
    final data =
        await signatureGlobalKey.currentState?.toImage(pixelRatio: 3.0);
    final bytes = await data?.toByteData(format: ui.ImageByteFormat.png);
    String tempPath = (await getTemporaryDirectory()).path;
    File file = File('$tempPath/signpostulation.png');
    await file.writeAsBytes(
        bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    print(file);

    if (data != null) {
      Navigator.pop(context, file);
      setState(() {
        AutoOrientation.portraitAutoMode();
      });
    }
  }

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

  @override
  void initState() {
    super.initState();
    AutoOrientation.landscapeAutoMode();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
        body: SingleChildScrollView(
            child: Column(
      //mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.08,
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: HexColor('EA6012'),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    AutoOrientation.portraitAutoMode();
                  });
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 5.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(l10n.sign_finger,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: HexColor('EA6012'))),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 80.0),
              padding: EdgeInsets.symmetric(vertical: 1.0),
              width: MediaQuery.of(context).size.width * 0.20,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(width: 5.0, color: HexColor('EA6012')),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
                child: Text(
                  l10n.delete,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: HexColor('EA6012')),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0),
              padding: EdgeInsets.symmetric(vertical: 1.0),
              width: MediaQuery.of(context).size.width * 0.20,
              child: OutlinedButton(
                //onPressed: () => select("English"),
                onPressed: _handleSaveButtonPressed,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(width: 5.0, color: HexColor('EA6012')),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
                child: Text(
                  l10n.accept,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: HexColor('EA6012')),
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Container(
          // alignment: Alignment.topLeft,
          margin: EdgeInsets.only(left: 20, right: 20.0),
          width: MediaQuery.of(context).size.width * 1.20,
          height: MediaQuery.of(context).size.height * 0.78,
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: HexColor('EA6012')),
              borderRadius: BorderRadius.circular(10)),
          child: SfSignaturePad(
              key: signatureGlobalKey,
              backgroundColor: Colors.white,
              strokeColor: Colors.black,
              minimumStrokeWidth: 2.0,
              maximumStrokeWidth: 4.0),
        ),
      ],
    )));
  }
}
