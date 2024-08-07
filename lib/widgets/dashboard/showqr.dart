import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/model/config.dart';
import '../../local/database_creator.dart';
import 'dart:ui';
import 'package:worker/widgets/dashboard/index.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../model/user.dart';

import '../../providers/client_notif.dart';
import '../../providers/notifications.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'dart:async';

import 'appbar.dart';
import 'badge_icon.dart';

class ShowQRWorker extends StatefulWidget {
  final Config config;

  ShowQRWorker({required this.config});
  @override
  State<ShowQRWorker> createState() => _ShowQRWorkerState(config);
}

class _ShowQRWorkerState extends State<ShowQRWorker> {
  Config config;
  _ShowQRWorkerState(this.config);

  int _selectedIndex = 2;

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

  @override
  void initState() {
    getTodo(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
          elevation: 2.0,
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: HexColor('EA6012'),
          ),
          title: Image.asset(
            "assets/nuevo-naranja.png",
            width: 120,
            alignment: Alignment.topLeft,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DashboardHome(
                        noti: false,
                        data: {},
                      )),
            ),
          ),
          actions: [
            IconButton(
                icon: BadgeIcon(
                    icon: ImageIcon(
                      AssetImage('assets/notif.png'),
                      size: 25,
                      color: Colors.grey,
                    ),
                    badgeCount: 0 //snapshot.data != 0 ? snapshot.data : _chats,
                    ),
                onPressed: () {
                  /* Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ListNotifications()),
                  );*/
                })
          ]),
      body: Column(
        //mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
              height: MediaQuery.of(context).size.height * 0.25,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(config != null
                          ? config.image
                          : this.widget.config.image),
                      fit: BoxFit.cover,
                      scale: 5))),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Container(
            child: Column(children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Text(
                  config != null
                      ? config.last_name + ' ' + config.first_name
                      : this.widget.config.last_name +
                          ' ' +
                          this.widget.config.first_name,
                  style: TextStyle(
                    color: HexColor('EA6012'),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  )),
              Text('ID#' + ' ' + this.widget.config.btn_id,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
              SizedBox(height: 30),
              QrImageView(
                data: config != null ? config.btn_id : widget.config.btn_id,
                version: QrVersions.auto,
                gapless: true,
                size: MediaQuery.of(context).size.width * 0.65,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
              ),
              /*QrImage(
                data:
                    config != null ? config.btn_id : widget.config.btn_id,
                gapless: true,
                size: MediaQuery.of(context).size.width * 0.65,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
              ),*/

              if (config.contract != 'null') ...[
                Text(
                  '',
                  style: TextStyle(
                    color: HexColor('EA6012'),
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
                Text(
                  config.contract,
                  style: TextStyle(
                    color: HexColor('707070'),
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                  ),
                ),
              ]
            ]),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          /* Container(
                  margin: EdgeInsets.only(left: 20.0, right: 20.0),
                  padding: EdgeInsets.symmetric(vertical: 1.0),
                  width: double.infinity,
                  child: OutlineButton(
                    borderSide: BorderSide(color: HexColor('EA6012')),
                    //onPressed: () => select("English"),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                      Navigator.of(ctx).pop();
                    },
                    padding: EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      AppTranslations.of(context).text("accept"),
                      style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: HexColor('EA6012'))),
                    ),
                    color: Colors.white,
                  ),
                ),*/

          /*Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: OutlineButton.icon(
                    borderSide: BorderSide(color: HexColor('EA6012')),
                    //onPressed: () => select("English"),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                      Navigator.of(ctx).pop();
                    },
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, left: 130, right: 130),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    icon: ImageIcon(
                      AssetImage('assets/enviar.png'),
                      color: HexColor('EA6012'),
                      size: 30,
                    ),
                    label: Text(
                      AppTranslations.of(context).text("accept"),
                      style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: HexColor('EA6012'))),
                    ),
                    color: Colors.white,
                  ),
                )*/
          SizedBox(
            height: 20,
          ),
        ],
      ),
      bottomNavigationBar: AppBarButton(
        noti: false,
        selectIndex: 2,
        rol: '',
      ),
    );
  }
}
