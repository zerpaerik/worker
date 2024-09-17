import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_radio_button_group/flutter_radio_button_group.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/user.dart';
import '../../../providers/auth.dart';
import '../../global.dart';
import '../../widgets.dart';
import 'camera_tax.dart';
import 'part_oblig.dart';

class EditDocumentProfile extends StatefulWidget {
  static const routeName = '/document-profile';
  final String? document;
  final User? user;

  EditDocumentProfile({this.document, this.user});

  @override
  _EditDocumentProfileState createState() =>
      _EditDocumentProfileState(document, user);
}

class _EditDocumentProfileState extends State<EditDocumentProfile> {
  late String? document = '';
  User? user;

  _EditDocumentProfileState(this.document, this.user);
  final _form = GlobalKey<FormState>();

  XFile? _documentPhoto;
  XFile? _documentSelfie;
  late String urlphoto = '';
  late String urlselfi = '';
  var _isLoading = false;
  late String _currText = '';
  var maskTextInputFormatter = MaskTextInputFormatter(
      mask: "###-##-####", filter: {"#": RegExp(r'[0-9]')});
  var maskTextInputFormatterItin = MaskTextInputFormatter(
      mask: "9##-##-####", filter: {"#": RegExp(r'[0-9]')});
  bool _isFoto = false;
  bool _isSelfie = false;
  XFile? imagedocument;
  late String numberDoc = '';

  // ignore: unused_element

  /*

  void _selectImage(File pickedImage) {
    _documentPhoto = pickedImage;
    urlphoto = _documentPhoto.path.toString();
  }

  void _selectImageS(File pickedImage) {
    _documentSelfie = pickedImage;
    urlselfie = _documentSelfie.path.toString();
  }*/

  Future<void> _takePicture() async {
    // ignore: deprecated_member_use
    final imageFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    if (imageFile == null) {
      return;
    }
    setState(() {
      _documentPhoto = imageFile;
    });
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    //final savedImage = await imageFile.copy('${appDir.path}/$fileName');
  }

  Future<void> _takeGallery() async {
    // ignore: deprecated_member_use
    final imageFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (imageFile == null) {
      return;
    }
    setState(() {
      _documentPhoto = imageFile;
    });
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    //final savedImage = await imageFile.copy('${appDir.path}/$fileName');
  }

  Future<dynamic> _saveForm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<Auth>(context, listen: false)
          .updatetax(_currText, numberDoc, imagedocument)
          .then((response) {
        setState(() {
          _isLoading = false;
        });
        print(response['status']);
        print(response['data']);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ViewProfileOblig(
                    user: widget.user!,
                  )),
        );
      });
    } catch (error) {}
  }

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  _navigatePhoto(BuildContext context) async {
    // Navigator.push devuelve un Future que se completará después de que llamemos
    // Navigator.pop en la pantalla de selección!

    final result = await availableCameras().then((value) => Navigator.push(
        context,
        // Crearemos la SelectionScreen en el siguiente paso!
        MaterialPageRoute(
          builder: (context) => CameraTax(_currText, value),
        )));

    /*final result = await Navigator.push(
        context,
        // Crearemos la SelectionScreen en el siguiente paso!
        MaterialPageRoute(
          builder: (context) => CameraTax(_currText),
        ));*/

    print('es imagen');
    print(result);
    setState(() {
      _documentPhoto = result;
      imagedocument = _documentPhoto;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    print('entro aqui');
    Size size = MediaQuery.of(context).size;

    void _showCamera() {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          //title: Text('An Error Occurred!'),
          content: Container(
            height: 50,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      child: IconButton(
                          icon: ImageIcon(
                            AssetImage(
                              'assets/camera.png',
                            ),
                            color: HexColor('EA6012'),
                          ),
                          onPressed: () {
                            _navigatePhoto(context);
                          }),
                    ),
                    Container(
                      child: TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            _navigatePhoto(context);
                          },
                          child: Container(
                              child: const Align(
                                  alignment: Alignment.topLeft,
                                  child: Text('Camera',
                                      style: TextStyle(color: Colors.black))))),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Form(
          key: _form,
          child: ListView(children: <Widget>[
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
                          Icons.edit,
                          color: HexColor('EA6012'),
                        ),
                        onPressed: () {
                          //Navigator.of(context).pop();
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
            Container(
                margin: EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    'assets/formw9.png',
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
                    l10n.form_w9,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: HexColor('EA6012')),
                  ),
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: FlutterRadioButtonGroup(
                    checkColor: HexColor('EA6012'),
                    activeColor: HexColor('EA6012'),
                    borderColor: HexColor('EA6012'),
                    items: [
                      l10n.select,
                      "SSN",
                      "ITIN",
                      l10n.ssn_process,
                      l10n.itin_process,
                      l10n.not_ssn_itin,
                    ],
                    distanceToCheckBox: 15,
                    distanceToNextItem: 40,
                    textStyle: TextStyle(
                      fontSize: 20,
                    ),
                    onSelected: (String selected) {
                      setState(() {
                        _currText = selected;
                      });
                      print(_currText);
                    })),
            if (_currText == 'SSN') ...[
              Container(
                margin: EdgeInsets.only(
                  left: 30,
                  right: 30,
                ),
                width: MediaQuery.of(context).size.width * 0.39,
                child: TextFormField(
                  initialValue: '',
                  decoration: InputDecoration(
                      labelText: l10n.number,
                      labelStyle: TextStyle(
                        fontSize: 18,
                      )),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [maskTextInputFormatter],
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return l10n.obligatory;
                    } else if (value.length < 8) {
                      return 'Verifica la longitud del número de documento';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    setState(() {
                      numberDoc = value!;
                    });
                    //_editedUser = User(id_number: value, id_type: _currText);
                  },
                  onChanged: (value) {
                    setState(() {
                      numberDoc = value;
                    });
                    //_editedUser = User(id_number: value, id_type: _currText);
                  },
                ),
              ),
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
                            border:
                                Border.all(width: 2, color: HexColor('EA6012')),
                            borderRadius: BorderRadius.circular(5)),
                        child: Stack(
                          children: <Widget>[
                            imagedocument != null
                                ? !_isFoto
                                    ? Center(
                                        child: GestureDetector(
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Image.file(
                                                File(imagedocument!.path),
                                                width: size.width,
                                                height: size.height,
                                                fit: BoxFit.fill,
                                              )),
                                        ),
                                      )
                                    : Image.file(
                                        File(imagedocument!.path),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                : Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 110,
                                      ),
                                      Container(
                                          child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Text(
                                                l10n.document_image,
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
                                              AssetImage(
                                                  'assets/camerawhite.png'),
                                              color: HexColor('EA6012'),
                                            ),
                                            onPressed: _showCamera,
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
            ],
            if (_currText == 'ITIN') ...[
              Container(
                margin: EdgeInsets.only(
                  left: 30,
                  right: 30,
                ),
                width: MediaQuery.of(context).size.width * 0.39,
                child: TextFormField(
                  initialValue: '',
                  decoration: InputDecoration(
                      labelText: l10n.number,
                      labelStyle: TextStyle(
                        fontSize: 18,
                      )),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [maskTextInputFormatter],
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return l10n.obligatory;
                    } else if (value.length < 8) {
                      return 'Verifica la longitud del número de documento';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    setState(() {
                      numberDoc = value!;
                    });
                    //_editedUser = User(id_number: value, id_type: _currText);
                  },
                  onChanged: (value) {
                    setState(() {
                      numberDoc = value;
                    });
                    //_editedUser = User(id_number: value, id_type: _currText);
                  },
                ),
              ),
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
                            border:
                                Border.all(width: 2, color: HexColor('EA6012')),
                            borderRadius: BorderRadius.circular(5)),
                        child: Stack(
                          children: <Widget>[
                            imagedocument != null
                                ? !_isFoto
                                    ? Center(
                                        child: GestureDetector(
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Image.file(
                                                File(imagedocument!.path),
                                                width: size.width,
                                                height: size.height,
                                                fit: BoxFit.fill,
                                              )),
                                        ),
                                      )
                                    : Image.file(
                                        File(imagedocument!.path),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                : Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 110,
                                      ),
                                      Container(
                                          child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Text(
                                                l10n.document_image,
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
                                              AssetImage(
                                                  'assets/camerawhite.png'),
                                              color: HexColor('EA6012'),
                                            ),
                                            onPressed: _showCamera,
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
            ],
            if (_currText == 'SSN en proceso' ||
                _currText == "SSN in process" ||
                _currText == 'ITIN en proceso' ||
                _currText == "ITIN in process") ...[
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
                            border:
                                Border.all(width: 2, color: HexColor('EA6012')),
                            borderRadius: BorderRadius.circular(5)),
                        child: Stack(
                          children: <Widget>[
                            imagedocument != null
                                ? !_isFoto
                                    ? Center(
                                        child: GestureDetector(
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: Image.file(
                                                File(imagedocument!.path),
                                                width: size.width,
                                                height: size.height,
                                                fit: BoxFit.fill,
                                              )),
                                        ),
                                      )
                                    : Image.file(
                                        File(imagedocument!.path),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                : Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 110,
                                      ),
                                      Container(
                                          child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Text(
                                                l10n.document_image,
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
                                              AssetImage(
                                                  'assets/camerawhite.png'),
                                              color: HexColor('EA6012'),
                                            ),
                                            onPressed: _showCamera,
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
            ],
            SizedBox(height: MediaQuery.of(context).size.height * 0.10),
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
                      onPressed: () {
                        setState(() {
                          /*_editedUser = User(
                              id_type: _currText,
                              id_number: _editedUser.id_number);*/
                        });

                        if (_currText == 'SSN' ||
                            _currText == 'ITIN' ||
                            _currText == 'SSN en proceso' ||
                            _currText == "SSN in process" ||
                            _currText == 'ITIN en proceso' ||
                            _currText == "ITIN in process") {
                          if (imagedocument == null) {
                            print('faltan ss');
                            print(_currText);
                          } else {
                            _saveForm();
                          }
                        } else {
                          _saveForm();
                        }
                      },
                      child: Text(
                        l10n.next,
                        style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                    ),
            ),
          ])),
    );
  }
}
