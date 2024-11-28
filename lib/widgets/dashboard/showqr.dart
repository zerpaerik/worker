import 'dart:io';

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
  late User _user = User(
      id: 0,
      first_name: '',
      email: '',
      birth_date: DateTime.now(),
      last_name: '',
      password2: '',
      gender: '',
      country: 0,
      state: 0,
      city: 0,
      address_1: 'address_1',
      address_2: 'address_2',
      birthplace: 'birthplace',
      is_us_citizen: false,
      id_type: '',
      id_number: '',
      doc_type: '',
      doc_expire_date: DateTime.now(),
      doc_image: File('file.txt'),
      doc_number: '',
      dependents_number: '',
      contact_first_name: '',
      contact_last_name: '',
      contact_phone: '',
      contact_email: '',
      signature: File('file.txt'),
      marital_status: '',
      blood_type: 0,
      rh_factor: 0,
      phone_number: '',
      zip_code: '',
      profile_image: File('file.txt'),
      degree_levels: '',
      speciality_or_degree: '',
      english_learning_method: '',
      english_learning_level: '',
      english_mastery: '',
      spanish_mastery: '',
      spanish_learning_method: '',
      spanish_learning_level: '',
      expertise_area: '',
      cv_file: File('file.txt'),
      btn_id: '',
      referral_code: '',
      doc_type_no: '',
      expiration_date_no: DateTime.now(),
      front_image_no: File('file.txt'),
      rear_image_no: File('file.txt'),
      i94_form_image: File('file.txt'),
      uscis_number: '',
      ssn_dependents_number: '',
      other_income: '',
      deduction_type: '',
      deduction_amount: '',
      tax_doc_file: File('file.txt'),
      state_name: '',
      city_name: '');

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
                      : widget.config.last_name +
                          ' ' +
                          widget.config.first_name,
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
        user: _user,
      ),
    );
  }
}
