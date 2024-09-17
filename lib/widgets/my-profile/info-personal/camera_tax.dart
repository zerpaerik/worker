import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:path_provider/path_provider.dart';

import '../../widgets.dart';

class CameraTax extends StatefulWidget {
  final String doc;
  final List<CameraDescription>? cameras;

  CameraTax(this.doc, this.cameras);

  @override
  _CameraTax2State createState() => _CameraTax2State(doc, cameras);
}

class _CameraTax2State extends State<CameraTax> {
  String doc;
  List<CameraDescription>? cameras;
  _CameraTax2State(this.doc, this.cameras);
  late CameraController cameraController;
  late int selectedCameraIndex = 0;
  late String imgPath = '';

  Future initCamera(CameraDescription cameraDescription) async {
    cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  /// Display camera preview

  Widget cameraPreview() {
    if (cameraController == null || !cameraController.value.isInitialized) {
      return Text(
        'Loading',
        style: TextStyle(
            color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
      );
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.withOpacity(0.8),
          leading: IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              if (widget.doc == 'SSN') ...[
                CustomPaint(
                  foregroundPainter: Paintest2(),
                  child: CameraPreview(cameraController),
                ),
                ClipPath(
                    clipper: Cliptest2(),
                    child: CameraPreview(cameraController))
              ],
              if (widget.doc == 'ITIN') ...[
                /* CustomPaint(
              foregroundPainter: Paintest2(),
              child: CameraPreview(cameraController),
            ),
            ClipPath(
                clipper: Cliptest2(), child: CameraPreview(cameraController))*/
                CameraPreview(cameraController)
              ],
            ],
          ),
        ));

    /*return AspectRatio(
      aspectRatio: cameraController.value.aspectRatio,
      child: CameraPreview(cameraController),
    );*/
  }

  Widget cameraControl(context) {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            FloatingActionButton(
              child: Icon(
                Icons.camera,
                color: Colors.black,
              ),
              backgroundColor: Colors.white,
              onPressed: () {
                onCapture(context);
              },
            )
          ],
        ),
      ),
    );
  }

  /*onCapture(context) async {
    try {
      final p = await getTemporaryDirectory();
      final name = DateTime.now();
      final path = "${p.path}/$name.png";

      await cameraController.takePicture(path).then((value) {
        print('here');
        print(path);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImageInputCamera(
                    //document: File.to,
                    )));
      });
    } catch (e) {
      showCameraException(e);
    }
  }*/

  onCapture(context) async {
    try {
      final p = await getTemporaryDirectory();
      final name = DateTime.now();
      final path = "${p.path}/$name.png";

      XFile picture = await cameraController.takePicture();
      Navigator.pop(context, picture);

      /* await cameraController.takePicture().then((value) {
        print('aaaaaaaa0');
        print(path);
        print(File(path));
      });*/
    } catch (e) {
      showCameraException(e);
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Stack(
          children: <Widget>[
//            Expanded(
//              flex: 1,
//              child: _cameraPreviewWidget(),
//            ),
            Align(
              alignment: Alignment.center,
              child: cameraPreview(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 120,
                width: double.infinity,
                padding: EdgeInsets.all(15),
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    //  cameraToggle(),
                    cameraControl(context),
                    Spacer(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  getCameraLensIcons(lensDirection) {
    switch (lensDirection) {
      case CameraLensDirection.back:
        return CupertinoIcons.switch_camera;
      case CameraLensDirection.front:
        return CupertinoIcons.switch_camera_solid;
      case CameraLensDirection.external:
        return CupertinoIcons.photo_camera;
      default:
        return Icons.device_unknown;
    }
  }

  showCameraException(e) {
    String errorText = 'Error ${e.code} \nError message: ${e.description}';
  }
}

class Paintest2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.grey.withOpacity(0.5), BlendMode.dstOut);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class Cliptest2 extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    print(size);
    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(10, size.height / 2 - 120, size.width - 20, 260),
          Radius.circular(26)));

    return path;
  }

  @override
  bool shouldReclip(oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}
