import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:package_info/package_info.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:worker/model/config.dart';
import 'package:worker/providers/travel.dart';
import 'package:worker/providers/workday.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../local/database_creator.dart';
import '../../local/service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../model/modules.dart';
import '../../providers/notifications.dart';
import 'package:worker/providers/url_constants.dart';

import '../global.dart';
import '../../model/user.dart';
import '../../model/workday.dart';
import '../../providers/auth.dart';
import '../../providers/notification_bloc.dart';
import 'appbar.dart';
import 'badge_icon.dart';
//import 'dashboard_business.dart';

//import 'dashboard_worker.dart';
import 'dashboard_worker.dart';
import 'menu_lat.dart';

class DashboardHome extends StatefulWidget {
  static const routeName = '/dashboard';

  final bool noti;
  final Map<dynamic, dynamic> data;
  DashboardHome({required this.noti, required this.data});

  @override
  _DashboardHomeState createState() => _DashboardHomeState(noti, data);
}

class _DashboardHomeState extends State<DashboardHome> {
  late bool noti;
  late Map<dynamic, dynamic> data;
  _DashboardHomeState(this.noti, this.data);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // ignore: avoid_init_to_null
  late User user = User(
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
  late String role;
  late Workday _wd = Workday(
      id: 0,
      created: DateTime.now(),
      clock_in_start: DateTime.now(),
      clock_in_end: DateTime.now(),
      clock_out_end: DateTime.now(),
      clock_out_start: DateTime.now(),
      default_init: DateTime.now(),
      default_exit: DateTime.now(),
      clock_in_location: '',
      clock_out_location: '');
  var jsonData;
  late User userModel;
  //bool noti = false;
  late String text =
      'Hola, Registrate en la mejor plataforma de empleo de EUA, a traves del siguiente enlace: $urlServices/user/register-worker?referralCode=';
  late String url = 'www.google.com';
  // ignore: unused_field
  late int _selectedIndex = 0;
  late Map<String, dynamic> hours = {};
  late Map<String, dynamic> travel_detail = {};
  late Map<String, dynamic> contract = {};
  late Map<String, dynamic> info = {};
  late String num_offers =
      ApiWebServer.server_name + '/api/v-1/contract/joboffer/not-accepted';

  late String isContract = '';
  late Modules module = Modules(
      clock_in_module: false,
      clock_out_module: false,
      expenses_module: false,
      warnings_module: false,
      workday_reports_module: false,
      role: '');
  late Map<String, dynamic> data_versions;

  late int travel;
  late bool _isLoading = false;
  late Config config = Config(0, '', token, role, '', '', '', '', '', 'btn_id',
      '', '', '', '', '', '', '');
  late String token = '';
  late int _currentIndex = 0;
  late String se;
  late File val;
  late var status;
  late bool _visibility = true;
  late bool visi;
  late bool _visibilit1 = true;
  late bool _visibilit2 = true;
  late bool _visibilitn = true;
  late bool isNotSession = false;
  late bool _noti = false;
  late int _notif = 0;

  late Timer _timer;
  late Timer _timer1;
  late Timer _timer2;
  late StreamSubscription<Map> _countSubscriptionIndex;
  late StreamController<int> _countControllerD = StreamController<int>();

  late int _tabBarCount1 = 0;

  // ignore: non_constant_identifier_names
  late List data_offers = [];
  late List dataf1 = [];
  late List datat = [];

  late int _start = 1;
  late PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  late StreamSubscription<Map> _notificationSubscription;

  void _changed(bool visibility) async {
    setState(() {
      if (_start == 30) {
        _visibility = visibility;
        visi = visibility;
      }
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs?.setBool("view1", true);
  }

  void startTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs?.setBool("view1", false);
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
        oneSec,
        (Timer timer) => setState(() {
              if (_start == 30) {
                timer.cancel();
                _changed(true);
              } else {
                _start = _start + 1;
              }
            }));
    setState(() {
      _visibility = false;
    });
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
      print('info de versión');
      print(_packageInfo.version);
      print(_packageInfo.buildNumber);
    });

    /*if (_packageInfo.version == '1.6.2') {
      _showInputDialog('Existe una versión nueva publicada');
    }*/
  }

  void _changed1(bool visibility) async {
    setState(() {
      if (_start == 50) {
        _visibilit1 = visibility;
      }
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs?.setBool("view1", true);
  }

  void startTimer1() async {
    /* setState(() {
      _visibility = false;
    });*/

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs?.setBool("view1", false);
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
        oneSec,
        (Timer timer) => setState(() {
              if (_start == 50) {
                timer.cancel();
                _changed1(true);
              } else {
                _start = _start + 1;
              }
            }));
    setState(() {
      _visibilit1 = false;
    });
  }

  void _changed2(bool visibility) async {
    setState(() {
      if (_start == 50) {
        _visibilit2 = visibility;
      }
    });
  }

  void startTimer2() async {
    /* setState(() {
      _visibility = false;
    });*/

    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
        oneSec,
        (Timer timer) => setState(() {
              if (_start == 50) {
                timer.cancel();
                _changed2(true);
              } else {
                _start = _start + 1;
              }
            }));
    setState(() {
      _visibilit2 = false;
    });
  }

  void _changedn(bool visibility) async {
    setState(() {
      if (_start == 30) {
        _visibilitn = visibility;
      }
    });
  }

  void startTimern() async {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
        oneSec,
        (Timer timer) => setState(() {
              if (_start == 30) {
                timer.cancel();
                _changedn(true);
              } else {
                _start = _start + 1;
              }
            }));
    setState(() {
      _visibilitn = false;
    });
  }

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  getChats() async {
    SharedPreferences chats = await SharedPreferences.getInstance();
    int? intValue = chats.getInt('intChatsValue');
    return intValue;
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

  verifyData() async {
    RepositoryServiceTodo.verifyData();
  }

  Future<dynamic> getM() async {
    String token = await getToken();

    var res = await http.get(
        Uri.parse(
            ApiWebServer.server_name + '/api/v-1/contract/modules-worker'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);
    print(resBody);

    if (res.statusCode == 200) {
      setState(() {
        module = Modules.fromJson(json.decode(res.body));
      });
      // print(module.workday_reports_module);
      RepositoryServiceTodo.updateModules(
          config,
          module.clock_in_module,
          module.clock_out_module,
          module.expenses_module,
          module.workday_reports_module,
          module.role);
    } else {
      // print(res.statusCode);
    }

    return "Sucess";
  }

  void _showviewOffers() {
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
              margin: EdgeInsets.only(left: 10),
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/offer.jpeg',
                width: 50,
                //color: HexColor('EA6012'),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                alignment: Alignment.center,
                child:
                    Text('¡Tienes ofertas recibidas pendientes por revisar!'))
          ],
        ),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: HexColor('EA6012'),
          fontSize: 17,
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Ver',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: HexColor('EA6012'),
                  fontSize: 17,
                )),
            onPressed: () {
              Navigator.of(ctx).pop();
              /* Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => JobOfferPage(
                          user: user,
                        )),
              );*/
              //JobOfferPage
            },
          ),
        ],
      ),
    );
  }

  void _showOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Logout'),
        content: Text('Logout'),
        titleTextStyle: TextStyle(
            color: HexColor('373737'),
            fontFamily: 'OpenSansRegular',
            fontWeight: FontWeight.bold,
            fontSize: 20),
        actions: <Widget>[
          TextButton(
            child: Text('No',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: HexColor('EA6012'))),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text(
              'Yes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            onPressed: () {
              Provider.of<Auth>(context, listen: false).logout();
              Navigator.of(context, rootNavigator: true).pop('/auth');
              Navigator.of(context).pushReplacementNamed('/auth');
            },
          )
        ],
      ),
    );
  }

  void _showSesion(context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.sure_logout),
        titleTextStyle: TextStyle(
            color: HexColor('373737'),
            fontFamily: 'OpenSansRegular',
            fontWeight: FontWeight.bold,
            fontSize: 20),
        actions: <Widget>[
          TextButton(
            child: Text('No',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: HexColor('EA6012'))),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text(
              l10n.si,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: HexColor('EA6012')),
            ),
            onPressed: () {
              Provider.of<Auth>(context, listen: false).logout();
              Navigator.of(context, rootNavigator: true).pop('/auth');
              Navigator.of(context).pushReplacementNamed('/auth');
            },
          )
        ],
      ),
    );
  }

  void _timesNotify() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var view1 = prefs.getBool('view1') ?? false;

    if (view1 == true) {
      setState(() {
        visi = true;
      });
    }
    print('es notif');
    print(view1);
  }

  Future<dynamic> getTravel() async {
    String token = await getToken();
    print('token');
    print(token);
    var res = await http.get(
        Uri.parse(ApiWebServer.server_name + '/api/v-1/travel/1'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);

    if (res.statusCode == 200) {
      setState(() {
        travel = res.statusCode;
        travel_detail = resBody;
      });
    } else {
      setState(() {
        travel = res.statusCode;
      });
      // print(res.statusCode);
    }

    return "Sucess";
  }

  void _viewUser() {
    Provider.of<Auth>(context, listen: false).fetchUser().then((value) {
      setState(() {
        _user = value['data'];
        user = value['data'];
        se = value['status'];
      });
      // ignore: unnecessary_null_comparison
      if (config != null &&
          config.id_type != 'business' &&
          user.phone_number == '0') {
        _showviewPhone();
      }
    });
  }

  /* void _viewDevice() {
    Provider.of<Auth>(context, listen: false).updateDevice().then((value) {
      print('response de update de device');
      print(value);
    });
  }*/

  void _viewContract() {
    Provider.of<Auth>(context, listen: false).fetchContract().then((value) {
      setState(() {
        contract = value['data'];
        isContract = value['status'];
      });
    });
  }

  void _viewWorkDay() {
    Provider.of<WorkDay>(context, listen: false).fetchWorkDay().then((value) {
      setState(() {
        _wd = value;
      });
    });
  }

  void _viewHours() {
    Provider.of<Auth>(context, listen: false).fetchHours().then((value) {
      setState(() {
        hours = value;
      });
    });

    print('hours');
    print(hours);
  }

  void _showviewRequestt() {
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
                'assets/aceptar-1.png',
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
                child: Text('¡Invitación de viaje aceptada!'))
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

  Future<dynamic> _submit(invitation, bool resp) async {
    setState(() {
      _isLoading = true;
    });
    try {
      Provider.of<TravelProvider>(context, listen: false)
          .accept(invitation, resp)
          .then((response) {
        setState(() {
          _isLoading = false;
        });
        if (response['status'] == '200') {
          _showviewRequestt();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DashboardHome(noti: false, data: {})),
          );
        } else {
          //_showErrorDialog('Verifique la información');
        }
        return response;
      });
    } catch (error) {}
    /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePartOblig2()),
          );*/
  }

  void _showScaffold(String message) {
    /*_scaffoldKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: HexColor('009444'),
    ));*/
  }

  Future<dynamic> getSWData() async {
    String token = await getToken();
    print('token');
    print(token);
    var res = await http.get(
        Uri.parse(ApiWebServer.server_name + '/api/v-1/user/additional_info'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);

    setState(() {
      info = resBody;
    });

    print('esinfo');
    print(res.statusCode.toString());

    if (res.statusCode != 200) {
      setState(() {
        //  isNotSession = true;
      });
      //_showviewRequest();
    }

    return info;
  }

  getNotif() async {
    SharedPreferences notif = await SharedPreferences.getInstance();
    int? intValue = notif.getInt('intValue');
    return intValue;
  }

  getCountNotif() async {
    _notif = await getNotif();
    print(_notif);
  }

  void _showviewRequest(context) {
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
              margin: EdgeInsets.only(left: 10),
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/alert.png',
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
                child: const Text('Session expired'))
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
            onPressed: () async {
              Navigator.of(ctx).pop();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs?.setBool("isLoggedIn", false);
              SharedPreferences prefrences =
                  await SharedPreferences.getInstance();
              await prefrences.clear();
              Navigator.of(context).pushReplacementNamed('/auth');
            },
          ),
        ],
      ),
    );
  }

  void _showviewPhone() {
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
              margin: EdgeInsets.only(left: 10),
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/call.png',
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
                child: Text('Debes actualizar tu número telefónico'))
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
              /*Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UpdatePhone(
                          user: user,
                        )),
              );*/
            },
          ),
        ],
      ),
    );
  }

  _launchPlay() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.emplooy.worker';
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchApp() async {
    const url = 'https://apps.apple.com/us/app/emplooy/id1539167347';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showInputDialog(String title, String version) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        context: context,
        builder: (ctx) {
          return Column(
            //mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.10,
              ),
              Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Text('Update app',
                    style: TextStyle(
                      color: HexColor('EA6012'),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.12,
              ),
              Image.asset(
                'assets/alert.png',
                width: 150,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.10,
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                child: Text('Update the app',
                    style: TextStyle(
                      //color: HexColor('EA6012'),
                      //fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                    textAlign: TextAlign.center),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20, top: 15),
                child: Text(' $version',
                    style: TextStyle(
                      //color: HexColor('EA6012'),
                      //fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
              ),
              Container(
                alignment: Alignment.topCenter,
                //width: MediaQuery.of(context).size.width * 0.70,
                child: ElevatedButton(
                  onPressed: () async {
                    if (Platform.isAndroid) {
                      _launchPlay();
                    } else {
                      _launchApp();
                    }
                  },
                  child: Text(
                    'Update now',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          );
        });
  }

  _launchURL(String dir) async {
    var url = dir;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<dynamic> getVersions() async {
    String token = await getToken();
    print('token');
    print(token);
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
      print('info de versión');
      print(_packageInfo.version);
      print(_packageInfo.buildNumber);
    });

    var res = await http.get(
        Uri.parse(ApiWebServer.server_name + '/api/v-2/app_versions/1'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(utf8.decode(res.bodyBytes));
    setState(() {
      data_versions = resBody;
    });
    print('data de versiones');
    print(data_versions['min_android_version']);
    if (Platform.isAndroid) {
      if (data_versions['min_android_version'].toString() !=
          _packageInfo.version.toString()) {
        _showInputDialog('Existe una versión nueva publicada',
            data_versions['min_android_version'].toString());
      }
    } else {
      if (data_versions['min_ios_version'].toString() !=
          _packageInfo.version.toString()) {
        _showInputDialog('Existe una versión nueva publicada', '');
      }
    }
  }

  Future<String> getSWDataToday() async {
    String token = await getToken();
    print('token');
    print(token);

    var res = await http.get(
        Uri.parse(ApiWebServer.server_name + '/api/v-1/notification/today'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(utf8.decode(res.bodyBytes));

    setState(() {
      datat = resBody;
      dataf1 = datat
          .where((datat) =>
              datat['data']['identifier'] != 'MESSAGE_CHAT' &&
              datat['verification_date'] == null)
          .toList();
    });
    print('notificaciones de hoy');
    print(dataf1.length);

    if (dataf1.length != 0) {
      //_showInputNotificaciones('Hay notificaciones pendientes por leer hoy');
    }

    return "Sucess";
  }

  @override
  void initState() {
    _viewContract();
    //getSWDataToday();
    this.getCountNotif();
    super.initState();
    _initPackageInfo();
    _viewWorkDay();
    //_viewHours();
    _viewUser();
    //_viewDevice();
    //this.getVersions();
    this.getSWData();
    if (isNotSession) {
      _showviewRequest(context);
    }
    //this.getTravel();
    this.getM();
    getTodo(1);
    _timesNotify();
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    _countSubscriptionIndex.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    final l10n = AppLocalizations.of(context)!;

    List<T> map<T>(List list, Function handler) {
      List<T> result = [];
      for (var i = 0; i < list.length; i++) {
        result.add(handler(i, list[i]));
      }
      return result;
    }

    return Scaffold(
        // key: _scaffoldKey,
        appBar: AppBar(
            elevation: 2.0,
            backgroundColor: Colors.white,
            centerTitle: true,
            //automaticallyImplyLeading: false,
            iconTheme: IconThemeData(
              color: HexColor('EA6012'),
            ),
            title: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DashboardHome(
                              noti: false,
                              data: {},
                            )),
                  );
                },
                child: Image.asset(
                  "assets/nuevo-naranja.png",
                  width: 120,
                )),
            //automaticallyImplyLeading: false,
            actions: [
              IconButton(
                  icon: BadgeIcon(
                      icon: const ImageIcon(
                        AssetImage('assets/notif.png'),
                        size: 25,
                        color: Colors.grey,
                      ),
                      badgeCount:
                          _notif //snapshot.data != 0 ? snapshot.data : _chats,
                      ),
                  onPressed: () {
                    /* Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ListNotifications(
                                    user: user,
                                  )),
                        );*/
                  })
            ]),
        drawer: MenuLateral(
          user: user,
          workday: _wd,
          contract: contract,
          modules: module,
        ),
        body: config != null &&
                config.id_type != null &&
                (config.id_type == 'business' || config.id_type == 'customer')
            ? const Text('Dashboard business')
            : SingleChildScrollView(
                child: Column(children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                /*   FlatButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TextValidate()),
                          );
                        },
                        child: Text('Test address')),*/

                //VERIFY ACOUNT BUSINESS OR WORKER
                /* if (config != null && config.id_type == 'business') ...[
                DashboardBusiness(),
              ],*/
                if (config != null &&
                    config.id_type != null &&
                    config.id_type != 'business') ...[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          margin: EdgeInsets.only(left: 25.0),
                          width: MediaQuery.of(context).size.width * 0.90,
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${l10n.hello}, ${config.first_name}',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700])),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.10,
                          alignment: Alignment.topRight,
                          child: ClipRRect(
                            child: Container(
                              alignment: Alignment.center,
                              // color: Colors.grey.withOpacity(0.1),
                              child: Container(
                                width: 50,
                                height: 50,
                                child: CircleAvatar(
                                  radius: 50.0,
                                  backgroundImage: NetworkImage(config.image),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  DashboardWorker(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ])),
        bottomNavigationBar: AppBarButton(
          user: _user,
          selectIndex: 0,
          noti: this.widget.data != null
              ? this.widget.data['identifier'] == 'MESSAGE_CHAT'
                  ? this.widget.noti
                  : false
              : false,
          rol: '',
        ));
  }
}
