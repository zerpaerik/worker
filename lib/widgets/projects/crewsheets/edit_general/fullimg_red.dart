import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

class FullImgRed extends StatefulWidget {
  final Function? onSelectImage;
  final String url;
  final File? img;

  FullImgRed({this.onSelectImage, required this.url, this.img});
  @override
  State createState() => _FullImgRed();
}

enum AppState1 {
  free,
  picked,
  cropped,
}

class _FullImgRed extends State<FullImgRed> {
  AppState1? state;

  File? _storedImage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: HexColor('EA6012'),
        ),
        title: Image.asset(
          "assets/homelogo.png",
          width: 120,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: GestureDetector(
        child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: <Widget>[
                Positioned.fill(
                  child: Image.network(widget.url),
                ),
                /* if (_storedImage != null) ...[
                  Positioned.fill(
                    child: Image(
                      image: AssetImage(_storedImage.path),
                      fit: BoxFit.fill,
                    ),
                  )
                ],*/
              ],
            )),
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
