import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/model/user.dart';
import 'package:worker/model/workday.dart';
import 'package:worker/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:worker/providers/workday.dart';

import '../../global.dart';
import '../contract_list.dart';
import 'detail_out.dart';
import 'detal_scan.dart';
import 'list.dart';

class QRSCANCREWOUT extends StatefulWidget {
  final int? workday;
  Map<String, dynamic>? contract;
  Map<String, dynamic>? crew;

  QRSCANCREWOUT({required this.workday, this.contract, this.crew});

  @override
  State<StatefulWidget> createState() =>
      _QRSCANCREWOUTState(workday, contract, crew);
}

class _QRSCANCREWOUTState extends State<QRSCANCREWOUT> {
  User? user;
  int? workday;
  DateTime? workdayDate;
  Map<String, dynamic>? contract;
  Map<String, dynamic>? crew;

  Workday? work;
  Map<String, dynamic>? wk;
  User? us;
  List categorys = [];
  var selectedValue;
  int? worker_category;
    Map<String, dynamic>? crewCurrent;


  _QRSCANCREWOUTState(this.workday, this.contract, this.crew);
  bool Done_Button = false;
  var qrText = "";
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool scanning = false;
  bool add = false;
  String? _scanBarcode = 'Unknown';
  Barcode? result;

  Future<String?> getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  void _showErrorDialog(String message) {
    print(message);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: HexColor('EA6012'))),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => QRSCANCREWOUT(
                        workday: widget.workday, contract: widget.contract)),
              );
            },
          )
        ],
      ),
    );
  }

  
  Future<String> getCrew() async {
    String? token = await getToken();
    setState(() {});
    var res = await http.get(
        Uri.parse('${ApiWebServer.server_name}/api/v-1/crew/current'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);

    setState(() {
      crewCurrent = resBody;
    });

    return '1';
  }

  Future<String> getSWData() async {
    print('consultando categorias');
    String? token = await getToken();

    final String url =
        '${ApiWebServer.server_name}/api/v-1/worker-category/${widget.contract!['contract_id']}';

    var res = await http
        .get(Uri.parse(url), headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);

    setState(() {
      categorys = resBody;
    });
    print('categorias');
    print(categorys);

    return "Sucess";
  }

  Future<bool?> scanQRWorker(
      String identification, String lat, String long) async {
    String? token = await getToken();
    String contract = widget.contract!['contract_id'].toString();
    String type= "";
 

    setState(() {
      scanning = true;
    });
    int? crew = widget.workday;
    print('datos de scan crew');
    print(identification);
    print(crew);
    final response = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/crew/$crew/user/$identification?clock_type=OUT'),
        headers: {"Authorization": "Token $token"});
    setState(() {});
    print(response.statusCode);
    print(response.body);

    var resBody = json.decode(response.body);

    if (response.statusCode == 200 && resBody['first_name'] != null) {
      print('dio 200 scan list');
      setState(() {
        scanning = false;
      });
      User _user = User.fromJson(resBody);
      setState(() {
        qrText = "";
        controller?.stopCamera();
        Done_Button = false;
      });

      if(resBody['checked_in'] == false){
        _showErrorDialog('This user has not been Checked in');

      } else {
          // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailCrewOut(
                  datas: resBody,
                  user: _user,
                  workday: widget.workday,
                  lat: lat,
                  long: long,
                  contract: widget.contract,
                  crew: widget.crew,
                )),
      );

      }

    
    } else if (response.statusCode == 403) {
      print(resBody['detail']);
      setState(() {
        qrText = "";
        controller?.stopCamera();
        Done_Button = false;
      });
      _showErrorDialog(resBody['detail']);
    } else {
      print('dio error');
      setState(() {
        scanning = false;
      });
      //The worker has already clocked-in
      String error = resBody['detail'];
      print(resBody);
      if (error == 'worker not belongs to a project') {
        setState(() {
          qrText = "";
          controller?.stopCamera();
          Done_Button = false;
        });
      }
      if (error == 'The worker has already clocked-in') {
        _showErrorDialog('QR ALREADY SCANNED');
        setState(() {
          qrText = "";
          controller?.stopCamera();
          Done_Button = false;
        });
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => QRSCANCREWOUT(
                  crew: widget.crew,
                  workday: widget.workday,
                  contract: widget.contract)),
        );
      }

      if (error == 'Not found.') {
        _showErrorDialog('Not found');
        setState(() {
          qrText = "";
          controller?.stopCamera();
          Done_Button = false;
        });
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ListCrew(workday: widget.workday, contract: widget.contract)),
        );
      }
    }

    return true;
  }

  void _showReads() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        backgroundColor: Colors.white,
        title: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/cargando.gif',
                width: 80,
                color: HexColor('EA6012'),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                alignment: Alignment.center,
                child: Text('¡Agregando a proyecto!'))
          ],
        ),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: HexColor('EA6012'),
          fontSize: 17,
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Ok',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: HexColor('EA6012'),
                  fontSize: 17,
                )),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
        getCrew();

    //this.getSWData();
  }

  void resumeCamera() {
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.focus_qr,
            style: TextStyle(color: HexColor('EA6012')),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.close, color: HexColor('EA6012')),
            onPressed: () async {
              print('cerramdo camara');
              setState(() {
                qrText = "";
                controller?.stopCamera();
                Done_Button = false;
              });
             Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ContractList(
                      location: widget.contract,
                    )),
              );
            },
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.flash_on,
                  color: Colors.yellow,
                ),
                onPressed: () {
                  setState(() {
                    controller?.toggleFlash();
                  });
                })
          ],
          elevation: 0.0,
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: <Widget>[
            if (add) ...[
              Container(
                //margin: EdgeInsets.only(left: 5),
                child: const Align(
                  alignment: Alignment.topCenter,
                  child: Text('Agregando a proyecto...',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      )),
                ),
              )
            ],
            Expanded(
              flex: 4,
              child: Container(
                  child: QRView(
                key: qrKey,
                onQRViewCreated: (controller) {
                  //351109
                  setState(() {
                    this.controller = controller;
                  });

                  resumeCamera();
                  controller.scannedDataStream.listen((scanData) {
                    setState(() {
                      result = scanData;
                    });
                    controller.dispose();
                    print('result code scaner');
                    scanQRWorker(result!.code!, '1111', '1111');
                  });
                },
                overlayMargin: EdgeInsets.only(left: 10, right: 10),
                onPermissionSet: (ctrl, p) =>
                    _onPermissionSet(context, ctrl, p),
                overlay: QrScannerOverlayShape(
                  borderColor: HexColor('EA6012'),
                  borderRadius: 2,
                  borderLength: 130,
                  borderWidth: 5,
                  overlayColor: Colors.black.withOpacity(0.9),
                ),
              )),
            ),
          ],
        ));
  }

  _isFlashOn(String current) {
    //return flash_on == current;
  }

  _isBackCamera(String current) {
    //  return back_camera == current;
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    /*controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData.toString();
        controller?.pauseCamera();
        //Done_Button = true;
      });
      scanQRWorker(qrText, '1111', '1111');

      print(qrText);
    });*/
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }
}

class Paintest extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.grey.withOpacity(0.9), BlendMode.dstOut);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class Cliptest extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    print(size);
    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(10, size.height / 2 - 95, size.width - 20, 200),
          Radius.circular(5)));
    return path;
  }

  @override
  bool shouldReclip(oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}
