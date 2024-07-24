import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

import '../../../model/user.dart';
import '../../../providers/auth.dart';
import '../../widgets.dart';

class ViewProfileCiud extends StatefulWidget {
  static const routeName = '/my-profile.ciud';
  final User user;

  ViewProfileCiud({
    required this.user,
  });

  @override
  _ViewProfileCiudState createState() => _ViewProfileCiudState(user);
}

class _ViewProfileCiudState extends State<ViewProfileCiud> {
  late User user;
  _ViewProfileCiudState(this.user);
  late File _documentPhoto;
  late File _documentSelfie;
  late String urlphoto;
  late String urlselfie;
  late var _isLoading = false;
  late String _currText = '';
  late var maskTextInputFormatter = MaskTextInputFormatter(
      mask: "###-##-####", filter: {"#": RegExp(r'[0-9]')});
  late var maskTextInputFormatterItin = MaskTextInputFormatter(
      mask: "9##-##-####", filter: {"#": RegExp(r'[0-9]')});
  late bool _isFoto = false;
  late bool _isSelfie = false;

  void _showCamera() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        //title: Text('An Error Occurred!'),
        content: Container(
          height: 100,
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
                          _takePicture();
                        }),
                  ),
                  Container(
                    child: TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _takePicture();
                        },
                        child: Container(
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text('Cámara')))),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    child: IconButton(
                        icon: ImageIcon(
                          AssetImage(
                            'assets/registro_imagen.png',
                          ),
                          color: HexColor('EA6012'),
                        ),
                        onPressed: () {
                          _takeGallery();
                        }),
                  ),
                  Container(
                    child: TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _takeGallery();
                        },
                        child: Container(
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text('Galeria')))),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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
      _documentPhoto = imageFile as File;
    });
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    // final savedImage = await imageFile.copy('${appDir.path}/$fileName');
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
      _documentPhoto = imageFile as File;
    });
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    //final savedImage = await imageFile.copy('${appDir.path}/$fileName');
  }

  Future<void> _saveForm() async {
    setState(() {
      _isLoading = true;
    });

    /* try {
      await Provider.of<Auth>(context, listen: false)
          .update21(_editedUser)
          .then((response) {
        setState(() {
          _isLoading = false;
        });
        if (response['status'] == '200') {
        } else {}
      });
    } catch (error) {}*/
  }

  @override
  Widget build(BuildContext context) {
    print('esaa');
    final l10n = AppLocalizations.of(context)!;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: ListView(children: <Widget>[
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
                      /*    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditDocumentProfile(
                                  user: this.widget.user,
                                )),
                      );*/
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
        if (this.widget.user.id_type != null) ...[
          Container(
            margin: EdgeInsets.only(
              left: 30,
              right: 30,
            ),
            width: MediaQuery.of(context).size.width * 0.39,
            child: TextFormField(
              initialValue: this.widget.user.id_type == '1'
                  ? 'SSN'
                  : this.widget.user.id_type == '2'
                      ? 'ITIN'
                      : this.widget.user.id_type == '3'
                          ? 'SSN en proceso'
                          : this.widget.user.id_type == '4'
                              ? 'ITIN en proceso'
                              : 'No tengo SSN ni ITIN',
              enabled: false,
              decoration: InputDecoration(
                  labelText: l10n.type,
                  labelStyle:
                      TextStyle(fontSize: 18, color: HexColor('EA6012'))),
              textInputAction: TextInputAction.done,
              inputFormatters: [maskTextInputFormatter],
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Es obligatorio!';
                }
                return null;
              },
              onSaved: (value) {},
              onChanged: (value) {},
            ),
          )
        ],
        if (this.widget.user.id_number != null) ...[
          Container(
            margin: EdgeInsets.only(
              left: 30,
              right: 30,
            ),
            width: MediaQuery.of(context).size.width * 0.39,
            child: TextFormField(
              initialValue:
                  /*'***-**-**' + this.widget.user.id_number != null
                  ? this.widget.user.id_number.toString().substring(9, 11)
                  :*/
                  this.widget.user.id_number.toString(),
              enabled: false,
              decoration: InputDecoration(
                  labelText: l10n.number,
                  labelStyle:
                      TextStyle(fontSize: 18, color: HexColor('EA6012'))),
              textInputAction: TextInputAction.done,
              inputFormatters: [maskTextInputFormatter],
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Es obligatorio!';
                }
                return null;
              },
              onSaved: (value) {},
              onChanged: (value) {},
            ),
          )
        ],
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        if (this.widget.user.tax_doc_file != null) ...[
          Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  l10n.document_image,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: HexColor('EA6012')),
                ),
              )),
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
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
                        this.widget.user.tax_doc_file != null
                            ? !_isFoto
                                ? Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        /* Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => FullPhoto(
                                                      url: this
                                                          .widget
                                                          .user
                                                          .tax_doc_file
                                                          .path,
                                                    )));*/
                                      },
                                      child: Opacity(
                                        opacity: 0.5,
                                        child: Image.network(
                                          this
                                              .widget
                                              .user
                                              .tax_doc_file!
                                              .path
                                              .toString(),
                                          width: size.width,
                                          height: size.height,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  )
                                : Image.network(
                                    widget.user.tax_doc_file!.path.toString(),
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
                                    children: <Widget>[],
                                  )),
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
          )
        ],
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
      ]),
    );
  }
}
