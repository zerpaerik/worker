import 'dart:io';

import 'package:worker/widgets/my-profile/info-personal/update_phone.dart';
import 'package:worker/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:hexcolor/hexcolor.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../model/gender.dart';
import '../../../model/user.dart';
import '../../../model/states.dart';

import '../../../providers/auth.dart';
import '../../global.dart';
import '../../widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../index.dart';
import 'part_address.dart';
import 'part_ciud.dart';
import 'part_oblig2.dart';
import 'tax.dart';

class ViewProfileOblig extends StatefulWidget {
  static const routeName = '/view-my-profile';

  final User user;

  ViewProfileOblig({required this.user});

  @override
  _ViewProfileObligState createState() => new _ViewProfileObligState(user);
}

class _ViewProfileObligState extends State<ViewProfileOblig> {
  late User? user;
  _ViewProfileObligState(this.user);
  late String sexo;
  late List<Gender> _genders = Gender.getGenders();
  late List<DropdownMenuItem<Gender>> _dropdownMenuItems;
  late Gender _selectedGender;
  late Map<String, dynamic>? dataUser = {};

  late List dataStates = [];
  late List dataCitys = [];
  late States _selectedState;
  late var _myselection;
  late var _myselection2;
  late String zipcode = '';
  List data = [];
  late int stateselect;
  late int cityselect;

  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

  // ignore: unused_field
  late String _myActivity = '';
  // ignore: unused_field
  late String _value = '';
  // ignore: unused_field
  late String _myActivityResult = '';
  late String name = '';
  // ignore: unused_field
  late var _isLoading = false;
  late User _user = User(
      id: 0,
      first_name: '',
      email: '',
      birth_date: DateTime.parse('0000-00-00'),
      last_name: '',
      password2: '',
      gender: '',
      country: 0,
      state: 0,
      city: 0,
      address_1: '-',
      address_2: '-',
      birthplace: '',
      is_us_citizen: false,
      id_type: '',
      id_number: '',
      doc_type: '',
      doc_expire_date: DateTime.parse('0000-00-00'),
      doc_image: null,
      doc_number: '',
      dependents_number: '',
      contact_first_name: '',
      contact_last_name: '',
      contact_phone: '',
      contact_email: '',
      signature: null,
      marital_status: '',
      blood_type: 0,
      rh_factor: 0,
      phone_number: '',
      zip_code: '',
      profile_image: null,
      degree_levels: '',
      speciality_or_degree: '',
      english_learning_method: '',
      english_learning_level: '',
      english_mastery: '',
      spanish_mastery: '',
      spanish_learning_method: '',
      spanish_learning_level: '',
      expertise_area: '',
      cv_file: null,
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

  String capitalize(String string) {
    if (string == null) {
      throw ArgumentError("string: $string");
    }

    if (string.isEmpty) {
      return string;
    }

    return string[0].toUpperCase() + string.substring(1);
  }

  Future<dynamic> getSWData() async {
    String token = await getToken();

    var res = await http.get(
        Uri.parse('${ApiWebServer.server_name}/api/v-1/address/state'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);

    setState(() {
      dataStates = resBody;
    });

    return "Sucess";
  }

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  void _viewUser() {
    Provider.of<Auth>(context, listen: false).fetchUser().then((value) {
      print('resultado data de usuario');
      print(value);
      setState(() {
        _user = value['data'];
      });
      print('data de address');
      print(_user.address_1);
      print(_user.gender);
    });
  }

  @override
  void initState() {
    getSWData();
    _viewUser();
    //this.getSWData1(this.widget.user.city);
    _myActivity = '';
    _value = '';
    _myActivityResult = '';
    super.initState();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    DateFormat format = DateFormat("yyyy-MM-dd");

    if (widget.user.gender == '1') {
      sexo = 'Male';
    } else {
      sexo = 'Female';
    }
    return Scaffold(
      //  endDrawer: EndDrawer(),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(left: 10),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyProfile(
                                    user: _user,
                                  )),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(right: 10),
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: Container(
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: HexColor('EA6012'),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyProfile(
                                    user: widget.user,
                                  )),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(left: 30),
            child: Align(
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/offer.jpeg',
                width: 50,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Container(
            margin: EdgeInsets.only(left: 30, right: 30),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(l10n.personal_information,
                  style: TextStyle(
                      fontSize: 25,
                      color: HexColor('EA6012'),
                      fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(left: 30),
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.key_first_name,
                              style: TextStyle(
                                  fontSize: 17, color: HexColor('EA6012'))),
                          Text(_user.first_name!),
                        ]),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(left: 10),
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.key_last_name,
                              style: TextStyle(
                                  fontSize: 17, color: HexColor('EA6012'))),
                          Text(_user.last_name!),
                        ]),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(left: 30),
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.birth_date,
                              style: TextStyle(
                                  fontSize: 17, color: HexColor('EA6012'))),
                          Text(_user.birth_date.toString().substring(0, 11)),
                        ]),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(left: 10),
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.gender,
                              style: TextStyle(
                                  fontSize: 17, color: HexColor('EA6012'))),
                          Text(sexo),
                        ]),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(left: 30),
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.key_email,
                              style: TextStyle(
                                  fontSize: 17, color: HexColor('EA6012'))),
                          Text(widget.user.email!),
                        ]),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(left: 10),
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.country_birth,
                              style: TextStyle(
                                  fontSize: 17, color: HexColor('EA6012'))),
                          Text(widget.user.birthplace ?? "N/A"),
                        ]),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Container(
              child: Card(
                  margin: EdgeInsets.only(left: 30, right: 30),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: HexColor('EA6012'), width: 1),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 10),
                              width: MediaQuery.of(context).size.width * 0.70,
                              child: Text(l10n.phone_number,
                                  style: TextStyle(
                                      fontSize: 17, color: HexColor('EA6012'))),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.topRight,
                              margin: EdgeInsets.only(right: 10),
                              width: MediaQuery.of(context).size.width * 0.30,
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: HexColor('EA6012'),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UpdatePhone(
                                              user: widget.user,
                                            )),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            // ignore: unnecessary_null_comparison
                            child: Text(_user.phone_number!),
                          )),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                    ],
                  ))),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Container(
              child: Card(
                  margin: EdgeInsets.only(left: 30, right: 30),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: HexColor('EA6012'), width: 1),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 10),
                              width: MediaQuery.of(context).size.width * 0.70,
                              child: Text(l10n.form_w9,
                                  style: TextStyle(
                                      fontSize: 17, color: HexColor('EA6012'))),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.topRight,
                              margin: EdgeInsets.only(right: 10),
                              width: MediaQuery.of(context).size.width * 0.30,
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: HexColor('EA6012'),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EditDocumentProfile(
                                              user: widget.user,
                                            )),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(_user != null
                                  ? _user.id_type != null
                                      ? _user.id_type == '1'
                                          ? 'SSN' +
                                              ' / ' +
                                              _user.id_number.toString()
                                          : _user.id_type == '2'
                                              ? 'ITIN' +
                                                  ' / ' +
                                                  _user.id_number.toString()
                                              : _user.id_type == '3'
                                                  ? l10n.ssn_process
                                                  : _user.id_type == '4'
                                                      ? l10n.itin_process
                                                      : l10n.not_ssn_itin
                                      : 'N/A'
                                  : '...'))),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                    ],
                  ))),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Container(
              child: Card(
                  margin: EdgeInsets.only(left: 30, right: 30),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: HexColor('EA6012'), width: 1),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 10),
                              width: MediaQuery.of(context).size.width * 0.70,
                              child: Text(l10n.address,
                                  style: TextStyle(
                                      fontSize: 17, color: HexColor('EA6012'))),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.topRight,
                              margin: EdgeInsets.only(right: 10),
                              width: MediaQuery.of(context).size.width * 0.30,
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: HexColor('EA6012'),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ViewProfileAddress(
                                              user: widget.user,
                                            )),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: Align(
                              alignment: Alignment.topLeft,
                              // ignore: unnecessary_null_comparison
                              child: Text(_user.address_1 != 'null'
                                  ? _user.address_1.toString()
                                  : 'S/D'))),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                    ],
                  ))),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Container(
              child: Card(
                  margin: EdgeInsets.only(left: 30, right: 30),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: HexColor('EA6012'), width: 1),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 10),
                              width: MediaQuery.of(context).size.width * 0.70,
                              child: Text(l10n.emergency_contact,
                                  style: TextStyle(
                                      fontSize: 17, color: HexColor('EA6012'))),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.topRight,
                              margin: EdgeInsets.only(right: 10),
                              width: MediaQuery.of(context).size.width * 0.30,
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: HexColor('EA6012'),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ViewProfileOblig2(
                                              user: _user,
                                            )),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                  '${_user.contact_last_name} ${_user.contact_first_name}'))),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                    ],
                  ))),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Container(
              child: Card(
                  margin: EdgeInsets.only(left: 30, right: 30),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: HexColor('EA6012'), width: 1),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 10),
                              width: MediaQuery.of(context).size.width * 0.70,
                              child: Text(l10n.legal_documents,
                                  style: TextStyle(
                                      fontSize: 17, color: HexColor('EA6012'))),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.topRight,
                              margin: EdgeInsets.only(right: 10),
                              width: MediaQuery.of(context).size.width * 0.30,
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: HexColor('EA6012'),
                                ),
                                onPressed: () {
                                  /* Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ListEmplooyment(
                                              user: _user,
                                            )),
                                  );*/
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Align(
                              alignment: Alignment.topLeft, child: Text(''))),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                    ],
                  ))),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        ],
      ),
    );
  }
}
