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
import 'detal_scan.dart';
import 'list.dart';

class QRSCANCREW extends StatefulWidget {
  final int? workday;
  Map<String, dynamic>? contract;
  Map<String, dynamic>? crew;

  QRSCANCREW({required this.workday, this.contract, this.crew});

  @override
  State<StatefulWidget> createState() =>
      _QRSCANCREWState(workday, contract, crew);
}

class _QRSCANCREWState extends State<QRSCANCREW> {
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

  _QRSCANCREWState(this.workday, this.contract, this.crew);
  bool Done_Button = false;
  var qrText = "";
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool scanning = false;
  bool add = false;
  String? _scanBarcode = 'Unknown';
  Barcode? result;

  Future<void> resumeCamera() async {
    try {
      if (Platform.isAndroid) {
        await controller?.pauseCamera();
      }
      await controller?.resumeCamera();
      
      setState(() {
        scanning = false;
        qrText = "";
        Done_Button = false;
      });
    } catch (e) {
      print('Error al reanudar la cámara: $e');
    }
  }

  Future<String?> getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<void> _showErrorDialog(String message) async {
    print(message);
    if (controller != null) {
      await controller!.pauseCamera();
    }
    setState(() {
      scanning = false;
      qrText = "";
      Done_Button = false;
    });
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
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
              onPressed: () async {
                Navigator.of(ctx).pop();
                if (mounted && controller != null) {
                  try {
                    setState(() {
                      scanning = false;
                      qrText = "";
                      Done_Button = false;
                    });
                    await resumeCamera();
                  } catch (e) {
                    print("Error resuming camera: $e");
                  }
                }
              },
            )
          ],
        ),
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
    String type = "";
    if (widget.crew!['clock_in_end'] == null) {
      type = "IN";
    } else {
      type = "OUT";
    }

    setState(() {
      scanning = true;
    });
    int? crew = widget.workday;
    print('datos de scan crew');
    print(identification);
    print(crew);

    try {
      final response = await http.get(
          Uri.parse(
              '${ApiWebServer.server_name}/api/v-1/crew/$crew/user/$identification?clock_type=$type'),
          headers: {"Authorization": "Token $token"});
      setState(() {});
      print(response.statusCode);
      print(response.body);

      var resBody = json.decode(response.body);
      print('response scan crew');
      print(response.statusCode);

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

        if (type == "OUT" && resBody['checked_in'] == false) {
          await _showErrorDialog('This user has not been Checked in');
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailCrew(
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
      } else if (response.statusCode.toString() == '403') {
        print(resBody['detail']);
        setState(() {
          qrText = "";
          controller?.pauseCamera();
          Done_Button = false;
        });
        await _showErrorDialog(resBody['detail']);
      } else if (response.statusCode == 404) {
        await _showErrorDialog('Error');
        setState(() {
          qrText = "";
          controller?.pauseCamera();
          Done_Button = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ListCrew(workday: widget.workday, contract: widget.contract)),
        );
      } else {
        print('dio error');
        setState(() {
          scanning = false;
        });
        String error = resBody['detail'];
        print(resBody);
        if (error == 'worker not belongs to a project') {
          setState(() {
            qrText = "";
            controller?.pauseCamera();
            Done_Button = false;
          });
        }
        if (error == 'The worker has already clocked-in') {
          await _showErrorDialog('QR ALREADY SCANNED');
          setState(() {
            scanning = false;
            qrText = "";
            Done_Button = false;
          });
          resumeCamera();
        }

        if (error == 'Not found.') {
          await _showErrorDialog('Not found');
          setState(() {
            qrText = "";
            controller?.pauseCamera();
            Done_Button = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ListCrew(workday: widget.workday, contract: widget.contract)),
          );
        }
      }
    } catch (e) {
      setState(() {
        scanning = false;
      });
      setState(() {
        qrText = "";
        controller?.stopCamera();
        Done_Button = false;
      });
      print('error 500');
      print(e);
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

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    
    // Asegurarnos de que la cámara esté activa al inicio
    resumeCamera();
    
    controller.scannedDataStream.listen((scanData) async {
      if (!scanning) {  // Evitar múltiples escaneos simultáneos
        setState(() {
          scanning = true;
          qrText = scanData.code ?? '';
          result = scanData;
        });
        
        await scanQRWorker(qrText, '1111', '1111');
        
        // El estado scanning se reiniciará en el diálogo
      }
    });
  }

  @override
  void initState() {
    super.initState();
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
          onPressed: () {
            setState(() {
              qrText = "";
              controller?.stopCamera();
              Done_Button = false;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ListCrew(
                      crew: widget.crew,
                      workday: widget.workday,
                      contract: widget.contract)),
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
              onQRViewCreated: _onQRViewCreated,
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
      )
    );
  }

  _isFlashOn(String current) {
    //return flash_on == current;
  }

  _isBackCamera(String current) {
    //  return back_camera == current;
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
