import 'dart:io';

import 'package:worker/model/config.dart';
import 'package:worker/widgets/dashboard/index.dart';
import 'package:worker/widgets/my-profile/body.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../local/database_creator.dart';

import '../../model/user.dart';
import '../../providers/auth.dart';
import '../dashboard/appbar.dart';
import '../dashboard/badge_icon.dart';

class MyProfile extends StatefulWidget {
  static const routeName = '/my-profile';
  final User user;

  // ignore: prefer_const_constructors_in_immutables
  MyProfile({required this.user});

  @override
  _MyProfileState createState() => _MyProfileState(user);
}

class _MyProfileState extends State<MyProfile> {
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
  late Config config = Config(
      0, '', '', '', '', '', '', '', '', 'btn_id', '', '', '', '', '', '', '');
  _MyProfileState(this.user);
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
  // ignore: unused_field
  late int _selectedIndex = 4;
  late Config configr = Config(
      0, '', '', '', '', '', '', '', '', 'btn_id', '', '', '', '', '', '', '');

  getTodo(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final todo = Config.fromJson(data.first);
    setState(() {
      configr = todo;
    });
    return todo;
  }

  void _viewUser() {
    Provider.of<Auth>(context, listen: false).fetchUser().then((value) {
      setState(() {
        _user = value['data'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _viewUser();
    getTodo(1);
  }

  /*void _viewUser() {
    Provider.of<Auth>(context, listen: false).fetchUser().then((value) {
      setState(() {
        user = value;
      });
    });
  }*/

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
                  builder: (context) => DashboardHome(noti: false, data: {})),
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
                  /*  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ListNotifications(
                              user: user,
                            )),
                  );*/
                })
          ]),

      /*endDrawer:
          MenuLateralProfile(user: _user != null ? _user : this.widget.user),*/
      body: BodyProfile(
        user: _user != null ? _user : this.widget.user,
        config: configr,
      ),
      bottomNavigationBar: AppBarButton(
        user: this.widget.user,
        selectIndex: 4,
        noti: false,
        rol: '',
      ),
    );
  }
}
