import 'dart:convert';
import 'dart:io';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/model/user.dart';
import 'package:worker/model/workday.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:worker/providers/url_constants.dart';

import '../global.dart';
import 'detail.dart';
import 'list.dart';

const flash_on = "FLASH ON";
const flash_off = "FLASH OFF";
const front_camera = "FRONT CAMERA";
const back_camera = "BACK CAMERA";

class QRSCANOUT extends StatefulWidget {
  final User? user;
  final int? workday;
  Map<String, dynamic>? contract;
  final Workday? work;
  Map<String, dynamic>? wk;

  QRSCANOUT(
      {required this.user,
      required this.workday,
      this.contract,
      this.work,
      this.wk});

  @override
  State<StatefulWidget> createState() =>
      _QRSCANOUTState(user!, workday!, contract!, work!, wk!);
}

class _QRSCANOUTState extends State<QRSCANOUT> {
  User user;
  int workday;
  Map<String, dynamic> contract;
  Workday work;
  Map<String, dynamic> wk;

  _QRSCANOUTState(this.user, this.workday, this.contract, this.work, this.wk);
  bool Done_Button = false;
  var qrText = "";
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool? scanning = false;
  Barcode? result;

  Future<String?> getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  void _showErrorDialogADD(String message, int worker) {
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
          ),
          TextButton(
              child: Text('Send offer'),
              onPressed: () {
                Navigator.of(ctx).pop();
                //_submitOffer(worker);
              })
        ],
      ),
    );
  }

  Future<void> _showErrorDialogg(String message) async {
    print(message);
    await showDialog(
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
            child: Text('Continue'),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => QRSCANOUT(
                        user: widget.user,
                        workday: widget.workday,
                        work: widget.work,
                        contract: widget.contract,
                        wk: widget.wk,
                      )),
            );
            },
          )
        ],
      ),
    );
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
                setState(() {
                  scanning = false; // Restablecer el estado de scanning
                });
                Navigator.of(ctx).pop();
                    Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => QRSCANOUT(
                    user: widget.user,
                    workday: widget.workday,
                    work: widget.work,
                    contract: widget.contract,
                    wk: widget.wk,
                  )),
        );
            
              /*  if (mounted && controller != null) {
                  try {
                    await controller!.resumeCamera();
                    await Future.delayed(Duration(milliseconds: 500));
                    setState(() {
                      scanning = true;
                      qrText = "";
                    });
                  } catch (e) {
                    print("Error resuming camera: $e");
                  }
                }*/
              },
            )
          ],
        ),
      ),
    );
  }



  Future<bool?> scanQRWorkerOut(
      String? identification, String lat, String long) async {
    String? token = await getToken();
    String contract = widget.contract!['contract_id'].toString();

    setState(() {
      scanning = true;
    });

    final response = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/user/get-registered-user/$identification/$contract/out'),
        headers: {"Authorization": "Token $token"});
    setState(() {});
    //print(response.statusCode);
    //print(response.body);
    var resBody = json.decode(response.body);
    if (response.statusCode == 200 && resBody['first_name'] != null)  {
      print('dio 200 scan list');
      print(resBody);
       int code = resBody['code'] ?? 0; // Asigna 0 si resBody['code'] es null
     
      print(resBody);
      print('code');
      print(code.toString());

      if (code == 4) {
        print('entro error');
        

        //_showErrorDialogg('This user does not have Clock in');
        print('paso 1');
    // Mostrar el mensaje de error
    await _showErrorDialog('This user does not have Clock in');
    print('paso 2');
     setState(() {
          qrText = "";
          Done_Button = false;
        });
        //Navigator.pop(context);
        //controller?.pauseCamera();
    
  

    // Navegar al siguiente widget
    /*Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ListClockOut(
                user: widget.user,
                workday: widget.workday,
                contract: widget.contract,
                work: widget.work,
                wk: widget.wk,
              )),
    );*/
} else {
        print('entro a hacer clockout');
        setState(() {
          scanning = false;
        });

        User _user = User.fromJson(resBody);
       

      setState(() {
        qrText = "";
        controller?.stopCamera();
        Done_Button = false;
      });
        
        // Pausar la cámara antes de navegar
      /*  if (controller != null) {
          await controller!.pauseCamera();
        }*/
        
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailClockOut(
                    user: _user,
                    workday: widget.work,
                    lat: lat,
                    long: long,
                    contract: widget.contract,
                    wk: widget.wk,
                    datas: resBody,
                  )),
        );
      }
    } else {
      print('dio error');
      setState(() {
        scanning = false;
      });
      //The worker has already clocked-in
      String error = resBody['detail'];
      if (error == 'worker not belongs to a project') {
        _showErrorDialogADD('Error', resBody['worker']);
        setState(() {
          qrText = "";
          Done_Button = false;
        });
        //Navigator.pop(context);
        //controller?.pauseCamera();

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ListClockOut(
                    user: widget.user,
                    workday: widget.workday,
                    contract: widget.contract,
                    work: widget.work,
                    wk: widget.wk,
                  )),
        );
      }
      if (error == 'The worker has already clocked out') {
        await _showErrorDialog('QR ALREADY SCANNED');
        setState(() {
          qrText = "";
          Done_Button = false;
        });
        if (controller != null) {
          await controller!.resumeCamera();
        }
      }
      /*else {
        _showErrorDialog('Verifique la información.');
      }*/
    }
  }

  void resumeCamera() {
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  void _onQRViewCreatedOut(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData as String;
      });
      scanQRWorkerOut(qrText, '1111', '1111');
    });
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
             
            //Navigator.pop(context);
            //controller?.pauseCamera();

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ListClockOut(
                        user: widget.user,
                        workday: widget.workday,
                        contract: widget.contract,
                        work: widget.work,
                        wk: widget.wk,
                      )),
            );
          },
        ),
        actions: <Widget>[
          IconButton(
              icon: const Icon(
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
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: (controller) {
                this.controller = controller;
                controller.scannedDataStream.listen((scanData) {
                  setState(() {
                    result = scanData;
                  });
                  scanQRWorkerOut(result?.code, '1111', '1111');
                });
              },
              overlayMargin: const EdgeInsets.only(left: 10, right: 10),
              overlay: QrScannerOverlayShape(
                borderColor: HexColor('EA6012'),
                borderRadius: 2,
                borderLength: 130,
                borderWidth: 5,
                overlayColor: Colors.black.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _isFlashOn(String current) {
    return flash_on == current;
  }

  _isBackCamera(String current) {
    return back_camera == current;
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }
}
