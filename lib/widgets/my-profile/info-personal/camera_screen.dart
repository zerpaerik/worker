import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:path_provider/path_provider.dart';

import '../../widgets.dart';
import 'update_image_profile.dart';

class CameraScreen extends StatefulWidget {
  final Function onSelectImage;

  CameraScreen(this.onSelectImage);
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController? cameraController;
  late List cameras = [];
  late int selectedCameraIndex = 1;
  String? imgPath;

  Future initCamera(CameraDescription cameraDescription) async {
    if (cameraController != null) {
      await cameraController!.dispose();
    }

    cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);

    cameraController!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    if (cameraController!.value.hasError) {
      print('Camera Error ${cameraController!.value.errorDescription}');
    }

    try {
      await cameraController!.initialize();
    } catch (e) {
      showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  /// Display camera preview

  Widget cameraPreview() {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Text(
        'Loading',
        style: TextStyle(
            color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
      );
    }
    return Scaffold(
        body: Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        alignment: FractionalOffset.center,
        children: <Widget>[
          Positioned.fill(
            child: AspectRatio(
                aspectRatio: cameraController!.value.aspectRatio,
                child: CameraPreview(cameraController!)),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(
                'assets/ovp1.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    ));
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
                Icons.camera_alt,
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

  Widget cameraToggle() {
    if (cameras == null || cameras.isEmpty) {
      return Spacer();
    }

    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          onPressed: () {
            onSwitchCamera();
          },
          icon: Icon(
            getCameraLensIcons(lensDirection),
            color: Colors.white,
            size: 24,
          ),
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

      await cameraController!.takePicture().then((value) {
        print('here');
        print(value.path);
        print(path);
        print(File(path));

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImageInputCamera(
                      document: value,
                    )));
      });
    } catch (e) {
      showCameraException(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AutoOrientation.portraitAutoMode();
    availableCameras().then((value) {
      cameras = value;
      if (cameras.isNotEmpty) {
        setState(() {
          selectedCameraIndex = 1;
        });
        initCamera(cameras[selectedCameraIndex]).then((value) {});
      } else {
        print('No camera available');
      }
    }).catchError((e) {
      print('Error : ${e.code}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey.withOpacity(0.8),
        leading: IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 40,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
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
                padding: EdgeInsets.only(
                  top: 20,
                ),
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    cameraToggle(),
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

  onSwitchCamera() {
    selectedCameraIndex =
        selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    initCamera(selectedCamera);
  }

  showCameraException(e) {
    String errorText = 'Error ${e.code} \nError message: ${e.description}';
  }
}

class Paint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.grey.withOpacity(0.8), BlendMode.dstOut);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class Clip extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    print(size);
    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(10, size.height / 3 - 120, size.width - 20, 400),
          Radius.circular(26)));
    return path;
  }

  @override
  bool shouldReclip(oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}
