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
import 'package:provider/provider.dart';
import 'package:worker/providers/workday.dart';

import '../global.dart';
import 'detail.dart';
import 'detail_add.dart';
import 'list.dart';

class QRSCAN extends StatefulWidget {
  final User? user;
  final int? workday;
  Map<String, dynamic>? contract;
  final Workday? work;
  Map<String, dynamic>? wk;
  final User? us;

  QRSCAN({this.user, this.workday, this.contract, this.work, this.wk, this.us});

  @override
  State<StatefulWidget> createState() =>
      _QRSCANState(user!, workday!, contract!, work!, wk!, us!);
}

class _QRSCANState extends State<QRSCAN> {
  User user;
  int workday;
  Map<String, dynamic> contract;
  Workday work;
  Map<String, dynamic> wk;
  User us;
  List categorys = [];
  var selectedValue;
  int worker_category = 0;

  _QRSCANState(
      this.user, this.workday, this.contract, this.work, this.wk, this.us);
  bool Done_Button = false;
  var qrText = "";
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool scanning = false;
  bool add = false;
  Barcode? result;

  Future<String?> getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<void> _showErrorDialogADD(String message, int worker) {
    print(message);
    return showDialog(
      context: context,
      barrierDismissible: false, // El usuario debe presionar el botón para continuar
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: HexColor('EA6012'))),
            Container(
              child: Text('Add worker',
                  style: TextStyle(
                    fontSize: 18,
                  )),
            ),
            Container(
              child: FormField(
                builder: (state) {
                  return Theme(
                      data: Theme.of(context).copyWith(),
                      child: DropdownButton(
                        isExpanded: true,
                        iconEnabledColor: HexColor('EA6012'),
                        hint: Text(
                          'Select',
                        ),
                        underline: Container(
                          height: 1,
                          color: Colors.white,
                        ),
                        items: categorys.map((item) {
                          return DropdownMenuItem(
                            child: Text(
                              item['name'],
                            ),
                            value: item,
                          );
                        }).toList(),
                        value: selectedValue,
                        onChanged: (value) => setState(() {
                          selectedValue = value;
                          worker_category = selectedValue['id'];
                          state.didChange(value);
                        }),
                      ));
                },
              ),
            ),
          ],
        ),
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: HexColor('EA6012')),
        actions: <Widget>[
          TextButton(
              child: Text('Add project'),
              onPressed: () {
                Navigator.of(ctx).pop();
                // Reiniciar el estado del escáner
                setState(() {
                  scanning = false;
                  qrText = "";
                  Done_Button = false;
                });
                addProyect(worker, worker_category);
                // Reanudar la cámara
                resumeCamera();
              })
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
            builder: (context) => QRSCAN(
                  workday: widget.workday,
                  contract: widget.contract,
                  wk: widget.wk,
                  work: widget.work,
                  us: widget.us,
                  user: widget.user,
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

  Future<String> getSWData() async {
    String? token = await getToken();

    final String url =
        '${ApiWebServer.server_name}/api/v-1/worker-category/${widget.contract!['contract_id']}';

    var res = await http
        .get(Uri.parse(url), headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);

    setState(() {
      categorys = resBody;
    });

    return "Sucess";
  }

  Future<bool?> scanQRWorker(
      String? identification, String lat, String long) async {
    String? token = await getToken();
    String contract = widget.contract!['contract_id'].toString();

    print('llego aqui');
    setState(() {
      scanning = true;
    });

    final response = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/user/get-registered-user/$identification/$contract/in'),
        headers: {"Authorization": "Token $token"});

    var resBody = json.decode(response.body);
    print('hay respuesta');

    if (response.statusCode == 200 && resBody['first_name'] != null) {
      User _user = User.fromJson(resBody);
      setState(() {
        qrText = "";
        controller?.stopCamera();
        Done_Button = false;
      });
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailClockIn(
                  user: _user,
                  workday: widget.workday,
                  lat: lat,
                  long: long,
                  contract: widget.contract,
                  wk: widget.wk,
                  work: widget.work,
                  us: widget.us,
                  datas: resBody,
                )),
      );
    } else {
      print('dio error aqui');
      setState(() {
        scanning = false;
      });
      
      print('Response body:');
      print(resBody);

      // Primero manejamos el caso de QR ya escaneado
      if (resBody['code']?.toString() == "already clock in" || 
          resBody['detail'] == 'The worker has already clocked-in') {
        
        await _showErrorDialog('QR ALREADY SCANNED');
        
        setState(() {
          qrText = "";
          Done_Button = false;
        });
        
        return false; // Retornamos false para indicar que hubo un error
      }
      
      // Luego manejamos otros casos de error
      String error = resBody['detail'] ?? '';
      
      if (error == 'worker not belongs to a project') {
        _showErrorDialogADD('The worker is not in the contract', resBody['worker']);
        return false; // Retornamos false para indicar error
      } else if (error == 'Not found.') {
        _showErrorDialog('Not found');
        return false; // Retornamos false para indicar error
      }
    }
    return null;
  }

  Future<dynamic> addProyect(int worker, cate) async {
    print('llego a add proyecto');
    print(worker);
    print(cate);
    String? token = await getToken();
    String contract = widget.contract!['contract_id'].toString();

    setState(() {
      add = true;
    });

    try {
      Provider.of<WorkDay>(context, listen: false)
          .addWorkerProject(contract, cate, worker, widget.wk)
          .then((response) {
        setState(() {
          add = false;
        });
        //getWorkdayOn(1);
        if (response['status'] == '200') {
          User _user = User.fromJson(response['data']);
          setState(() {
            qrText = "";
            controller?.pauseCamera();
            Done_Button = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailClockInAdd(
                      user: _user,
                      workday: widget.workday,
                      lat: '111',
                      long: '111',
                      contract: widget.contract,
                      wk: widget.wk,
                      work: widget.work,
                      us: widget.us,
                      datas: response['data'],
                    )),
          );

          /*  Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QRSCAN(
                      user: _user,
                      workday: widget.workday,
                      contract: widget.contract,
                      wk: widget.wk,
                      work: widget.work,
                      us: widget.us,
                    )),
          );*/
        } else if (response['status'] == '400') {
          setState(() {
            qrText = "";
            controller?.pauseCamera();
            Done_Button = false;
          });
          if (response['data']['code'] == 'WAC') {
            _showErrorDialog('WAC');
          } else {
            _showErrorDialog('Error');
          }
        } else {
          _showErrorDialog('Error');
        }
      });
    } catch (error) {}
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
                child: Text('Adding project'))
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

  void resumeCamera() async {
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

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    
    // Asegurarnos de que la cámara esté activa al inicio
    resumeCamera();
    
    controller.scannedDataStream.listen((scanData) async {
      if (!scanning) {  // Evitar múltiples escaneos simultáneos
        setState(() {
          scanning = true;
          qrText = scanData.code ?? '';
        });
        
        await scanQRWorker(qrText, '1111', '1111');
        
        // El estado scanning se reiniciará en el diálogo
      }
    });
  }

  @override
  void initState() {
    print('data en qr scan');
    print(widget.wk);

    super.initState();
    getSWData();
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
              //Navigator.pop(context);
              setState(() {
                qrText = "";
                controller?.stopCamera();
                Done_Button = false;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ListClockIn(
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
              Align(
                alignment: Alignment.topCenter,
                child: Text(l10n.adding_project,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    )),
              ),
            ],
            Expanded(
              flex: 4,
              child: Container(
                  child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlayMargin: const EdgeInsets.only(left: 10, right: 10),
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

  @override
  void dispose() {
    controller?.dispose();
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
