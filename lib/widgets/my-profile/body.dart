import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../global.dart';
import '../../model/user.dart';
import '../../model/config.dart';
import 'package:http/http.dart' as http;
import '../../local/database_creator.dart';

import 'config.dart';
import 'data-request.dart';
import 'info-personal/part_acad.dart';
import 'info-personal/part_oblig.dart';
import 'job-offer/list.dart';

class BodyProfile extends StatefulWidget {
  final User user;
  final Config config;

  BodyProfile({required this.user, required this.config});

  @override
  _BodyProfileState createState() => _BodyProfileState(user, config);
}

class _BodyProfileState extends State<BodyProfile> {
  late User user;
  late Config config;
  _BodyProfileState(this.user, this.config);
  late final User _user = User(
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
  late Map<String, dynamic> info = {};
  late Map<String, dynamic> data_business = {};

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
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

  Future<dynamic> getSWData() async {
    String token = await getToken();
    var res = await http.get(
        Uri.parse('${ApiWebServer.server_name}/api/v-1/user/additional_info'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);

    setState(() {
      info = resBody;
    });
    print(info);

    return info;
  }

  void _viewUser() {
    /* Provider.of<Auth>(context, listen: false).fetchUser1().then((value) {
      setState(() {
        _user = value;
      });
    });*/
  }

  void _metricsBusiness(estatus) {
    print('consultando');
    Provider.of<Auth>(context, listen: false)
        .fetchMetricsBusiness(estatus)
        .then((value) {
      setState(() {
        data_business = value;
      });

      print('data business');
      print(data_business);
    });
  }

  @override
  void initState() {
    super.initState();
    getTodo(1);
    this.getSWData();
    _metricsBusiness('active');
    _viewUser();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_user != null) {
      print('user image');
      print(_user.profile_image);
      print('usr config');
      print(config.image);
      print('usr emplooyid');
      print(config.btn_id);
    }
    void _showInputDialog(String title) {
      showModalBottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          context: context,
          builder: (ctx) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 50,
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Text(title,
                      style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center),
                ),
                SizedBox(
                  height: 10,
                ),
                Image.asset(
                  'assets/alert.png',
                  width: 90,
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                          //margin: EdgeInsets.only(left: 20),
                          alignment: Alignment.center,
                          //height: MediaQuery.of(context).size.width * 0.1,
                          width: MediaQuery.of(context).size.width * 0.50,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 1.0),
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    width: 5.0, color: HexColor('EA6012')),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                              ),
                              child: Text(
                                '',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: HexColor('EA6012')),
                              ),
                            ),
                          )),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            );
          });
    }

    String bodyImage = "";
    bodyImage =
        widget.config.image.isNotEmpty && widget.config.image.contains("http")
            ? widget.config.image
            : "";
    bodyImage = config.image.isNotEmpty && config.image.contains("http")
        ? config.image
        : "";
    print(
        "body_image ${config.image} ${widget.config.image.isNotEmpty ? widget.config.image : config.image}");
    return Stack(
      children: [
        FittedBox(
            fit: BoxFit.contain,
            child: Container(
                height: MediaQuery.of(context).size.height * 0.15,
                width: /*double.infinity*/ MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: HexColor('EA6012'),
                    gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                      colors: [
                        HexColor('FBB03B'),
                        HexColor('EF6826'),
                      ],
                    )))),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
        ),
        Container(
            margin: EdgeInsets.only(top: 15),
            child: Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                  onTap: () {
                    /*  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UpdateProfile(
                                user: this.widget.user,
                                config: config,
                              )),
                    );*/
                  },
                  child: CircleAvatar(
                    radius: 80.0,
                    backgroundImage: NetworkImage(bodyImage),
                  )),
            )),
        Container(
            padding: EdgeInsets.only(top: 130.0),
            child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.07,
                    ),
                    Text(
                        this.widget.config.last_name +
                            ' ' +
                            this.widget.config.first_name,
                        style: TextStyle(
                          color: HexColor('EA6012'),
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        )),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Text(widget.config.email,
                        style: TextStyle(
                            color: HexColor('707070'),
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Text('ID#' + ' ' + widget.config.btn_id,
                        style: TextStyle(
                          color: HexColor('707070'),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        )),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.90,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(
                                //color: HexColor('009444'),
                                alignment: Alignment.topCenter,
                                //margin: EdgeInsets.only(left: 10),
                                //height: MediaQuery.of(context).size.width * 0.1,
                                width: MediaQuery.of(context).size.width * 0.28,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.28,
                                  height:
                                      MediaQuery.of(context).size.height * 0.12,
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 2),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.01,
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          /*Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CertifactionsPage(
                                                          user: user)));*/
                                        },
                                        child: Image.asset(
                                          'assets/Certifications.png',
                                          width: 35,
                                        ),
                                      ),
                                      SizedBox(
                                          height: 10,
                                          child: TextButton(
                                              onPressed: () {
                                                /* Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            CertifactionsPage(
                                                                user: user)));*/
                                              },
                                              child: Text(
                                                l10n.certifications,
                                                style: TextStyle(
                                                  //color: HexColor('707070'),
                                                  color: HexColor('EA6012'),
                                                  //fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                ),
                                              )))
                                    ],
                                  ),
                                )),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                                //color: HexColor('009444'),
                                alignment: Alignment.topCenter,
                                //margin: EdgeInsets.only(left: 10),
                                //height: MediaQuery.of(context).size.width * 0.1,
                                width: MediaQuery.of(context).size.width * 0.28,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.28,
                                  height:
                                      MediaQuery.of(context).size.height * 0.12,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.01,
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        child: Image.asset(
                                          'assets/Warnings.png',
                                          width: 35,
                                        ),
                                      ),
                                      SizedBox(
                                          height: 10,
                                          child: TextButton(
                                              onPressed: () {},
                                              child: Text(
                                                l10n.warnings,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10,
                                                ),
                                              )))
                                    ],
                                  ),
                                )),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                                alignment: Alignment.topCenter,
                                width: MediaQuery.of(context).size.width * 0.28,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.28,
                                  height:
                                      MediaQuery.of(context).size.height * 0.12,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.01,
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (user.id_type == '1' ||
                                              user.id_type == '2') {
                                          } else {
                                            _showInputDialog(l10n.alert_tax);
                                          }
                                        },
                                        child: Image.asset(
                                          'assets/Taxes.png',
                                          width: 35,
                                        ),
                                      ),
                                      SizedBox(
                                          height: 10,
                                          child: TextButton(
                                              onPressed: () {
                                                if (user.doc_type == '1' ||
                                                    user.doc_type == '2') {
                                                } else {
                                                  _showInputDialog(
                                                      l10n.alert_tax);
                                                }
                                              },
                                              child: Text(
                                                l10n.taxes,
                                                style: TextStyle(
                                                  color: HexColor('707070'),
                                                  fontSize: 10,
                                                ),
                                              )))
                                    ],
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 25.0, right: 25),
                      //padding: EdgeInsets.symmetric(vertical: 1.0),
                      // width: MediaQuery.of(context).size.width * 0.8,
                      child: OutlinedButton(
                        //onPressed: () => select("English"),
                        onPressed: () async {
                          /*await FlutterShare.share(
                            title: AppTranslations.of(context).text("referral"),
                            text: AppTranslations.of(context).text("referral1"),
                            linkUrl: '$urlServices/auth/register/' +
                                _user.referral_code,
                          );*/
                        },
                        style: OutlinedButton.styleFrom(
                          side:
                              BorderSide(width: 5.0, color: HexColor('EA6012')),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                        ),
                        child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              l10n.recomp,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: HexColor('EA6012')),
                            )),
                      ),
                    ),
                  ],
                ))),
        Container(
            margin: EdgeInsets.only(top: 480),
            height: MediaQuery.of(context).size.height * 0.30,
            child: ListView(
              children: [
                if (config != null && config.id_type != 'business') ...[
                  Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewProfileOblig(
                                          user: this.widget.user)),
                                );
                              },
                              icon: ImageIcon(
                                AssetImage('assets/Personal-Information.png'),
                                color: Colors.black,
                              ),
                              label: Row(
                                children: <Widget>[
                                  Text(
                                    l10n.info_per,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )))),
                  Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewProfileAcad(
                                          user: this.widget.user)),
                                );
                              },
                              icon: ImageIcon(
                                AssetImage('assets/Academic-Information.png'),
                                color: Colors.black,
                              ),
                              label: Text(
                                l10n.info_acad,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              )))),
                  Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          JobOfferPage(user: this.widget.user)),
                                );
                              },
                              icon: ImageIcon(
                                AssetImage('assets/Job-Offers.png'),
                                color: Colors.black,
                              ),
                              label: Text(
                                l10n.job_offer,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              )))),
                  Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DataRequestProfile(
                                            user: this.widget.user,
                                          )),
                                );
                              },
                              icon: ImageIcon(
                                AssetImage('assets/elegibilidad.png'),
                                color: Colors.black,
                              ),
                              label: Text(
                                l10n.mod_perfil,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ))))
                ],
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ConfigPage(
                                          user: user,
                                        )),
                              );
                            },
                            icon: ImageIcon(
                              AssetImage('assets/005-gear.png'),
                              color: Colors.black,
                            ),
                            label: Text(
                              l10n.setting,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )))),
              ],
            ))
        /*Container(
            height: MediaQuery.of(context).size.height * 0.30,
            child: ListView(
              children: [
                Text('1'),
                Text('1'),
                Text('1'),
                Text('1'),
                Text('1'),
                Text('1'),
                Text('1'),
                Text('1'),
                Text('2'),
                Text('2'),
              ],
            ))*/
      ],
    );
  }
}
