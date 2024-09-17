import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:camera/camera.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/model/config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:worker/widgets/dashboard/index.dart';
import 'package:worker/widgets/my-profile/info-personal/camera_page.dart';
import '../../../local/database_creator.dart';
import '../../../local/service.dart';
import '../../global.dart';
import 'package:http/http.dart' as http;
import 'package:worker/providers/url_constants.dart';

import 'camera_screen.dart';

class ImageInputCamera extends StatefulWidget {
  static const routeName = '/add-profile-picture';

  final XFile? document;

  ImageInputCamera({this.document});

  @override
  _ImageInputCameraState createState() => _ImageInputCameraState(document!);
}

enum AppState {
  free,
  picked,
  cropped,
}

class _ImageInputCameraState extends State<ImageInputCamera> {
  AppState? state;
  late File? _storedImage;
  XFile document;
  _ImageInputCameraState(this.document);

  // ignore: unused_field
  late File? _storedImageC;
  late String? _imagePath;
  late File? val;
  var _isLoading = false;
  late CameraController? controller;
  bool? _isFoto = false;
  bool loading = false;
  CameraController? cameraController;
  late List cameras = [];
  int selectedCameraIndex = 1;
  Config? config;

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
      // showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void initState() {
    //onLocaleChange(Locale(languagesMap['Español']));
    super.initState();
    state = AppState.free;
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

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<void> _takePicture() async {
    await availableCameras().then((value) => Navigator.push(context,
        MaterialPageRoute(builder: (_) => CameraPage(cameras: value))));
    /*Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraScreen(_selectImage)),
    );*/
  }

  void _selectImage(File pickedImage) {
    _storedImage = pickedImage;
  }

  getTodo(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final todo = Config.fromJson(data.first);
    setState(() {
      config = todo;
    });
    return todo;
  }

  Future<void> _saveForm() async {
    setState(() {
      _isLoading = true;
    });

    String token = await getToken();
    print('aqui');
    print(widget.document!.path);

    config = await getTodo(1);

    Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath(
        'profile_image', widget.document!.path.toString()));
    var streamedResponse = await request.send();

    var response = await http.Response.fromStream(streamedResponse);
    print('response');
    print(response);
    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
      });

      Map<String, dynamic> success = {
        "data": json.decode(response.body),
      };

      RepositoryServiceTodo.updateImage(
          config!, success['data']['details']['profile_image']);

      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DashboardHome(
                  noti: false,
                  data: {},
                )),
      );
    } else {
      print('error');
      print(response.body);
      setState(() {
        _isLoading = false;
      });
    }

    /// print(response.body);

    /* try {
      print('va a prov1');

      Provider.of<Auth>(context, listen: false)
          .update1(this.widget.document)
          .then((response) {
        setState(() {
          _isLoading = false;
        });
        if (response['status'] == '200') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TypeTax()),
          );
        } else {}
      });
    } catch (error) {}*/
  }

  Future<ImageProvider<Object>> xFileToImage(XFile xFile) async {
    final Uint8List bytes = await xFile.readAsBytes();
    return Image.memory(bytes).image;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Size size = MediaQuery.of(context).size;
    // globalContext receives context from StetelessWidget.

    return Scaffold(
        body: Form(
            child: ListView(
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.04,
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.only(left: 20),
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
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    }

                    // Navigator.pop(globalContext) // POPPING globalContext
                    ,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(right: 20),
                width: MediaQuery.of(context).size.width * 0.50,
                child: Container(
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: HexColor('EA6012'),
                    ),
                    onPressed: () {
                      // _showOut();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Row(
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(l10n.profile_picture,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                )),
            Container(
                margin: EdgeInsets.only(left: 5, top: 4),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(l10n.documentationp,
                      style:
                          TextStyle(fontSize: 14, color: HexColor('EA6012'))),
                )),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.width * 0.06,
        ),
        Container(
            margin: EdgeInsets.only(left: 30),
            child: Align(
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/cam_naranja.png',
                width: 70,
              ),
            )),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Container(
            margin: EdgeInsets.only(left: 30, right: 30),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                l10n.profile_picture,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: HexColor('EA6012')),
              ),
            )),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(left: 30),
                width: MediaQuery.of(context).size.width * 0.50,
                child: Container(
                  alignment: Alignment.topLeft,
                  //width: MediaQuery.of(context).size.width * 0.30,
                  height: MediaQuery.of(context).size.height * 0.35,
                  decoration: BoxDecoration(
                      border: Border.all(width: 2, color: HexColor('EA6012')),
                      borderRadius: BorderRadius.circular(5)),
                  child: Stack(
                    children: <Widget>[
                      widget.document != null
                          ? !_isFoto!
                              ? Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      /* Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => FullImg(
                                                    url: this
                                                        .widget
                                                        .document
                                                        .path,
                                                    img: this.widget.document,
                                                  )));*/
                                    },
                                    child: Opacity(
                                      opacity: 0.5,
                                      child: Image.file(File(widget.document!
                                          .path)) /*Image.file(
                                        this.widget.document,
                                        width: size.width,
                                        height: size.height,
                                        fit: BoxFit.fill,
                                      )*/
                                      ,
                                    ),
                                  ),
                                )
                              : Image.file(File(widget.document!.path))
                          : Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 110,
                                ),
                                Container(
                                    child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Text(
                                          l10n.profile_picture,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: HexColor('EA6012')),
                                        ))),
                              ],
                            ),
                      Positioned(
                        bottom: 0.5,
                        right: 0.8,
                        child: Column(
                          children: <Widget>[
                            Container(
                                height: 48,
                                width: 60,
                                child: Column(
                                  children: <Widget>[
                                    IconButton(
                                      icon: ImageIcon(
                                        AssetImage('assets/camerawhite.png'),
                                        color: HexColor('EA6012'),
                                      ),
                                      onPressed: _takePicture,
                                    ),
                                  ],
                                )),
                            Text(
                              'Re Take',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(right: 20),
                width: MediaQuery.of(context).size.width * 0.50,
                child: Container(
                  child: Text(''),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.06),
        Container(
          alignment: Alignment.topRight,
          margin: EdgeInsets.only(right: 30),
          //width: MediaQuery.of(context).size.width * 0.70,
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(HexColor('EA6012')),
                  ),
                  onPressed: widget.document != null ? _saveForm : null,
                  child: Text(
                    l10n.update_next,
                    style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ),
        ),
      ],
    )));
  }
}
