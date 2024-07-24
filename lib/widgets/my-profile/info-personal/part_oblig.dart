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

class ViewProfileOblig extends StatefulWidget {
  static const routeName = '/view-my-profile';

  final User user;

  ViewProfileOblig({required this.user});

  @override
  _ViewProfileObligState createState() => new _ViewProfileObligState(user);
}

class _ViewProfileObligState extends State<ViewProfileOblig> {
  late User user;
  _ViewProfileObligState(this.user);
  late String sexo;
  late List<Gender> _genders = Gender.getGenders();
  late List<DropdownMenuItem<Gender>> _dropdownMenuItems;
  late Gender _selectedGender;

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
  late User _user;

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
    Provider.of<Auth>(context, listen: false).fetchUser1().then((value) {
      setState(() {
        _user = value;
      });
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
    DateFormat format = DateFormat("yyyy-MM-dd");
    final l10n = AppLocalizations.of(context)!;

    if (widget.user.gender == '1') {
      sexo = 'Masculino';
    } else {
      sexo = 'Femenino';
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
                                    user: widget.user,
                                    config: null,
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
                                    config: null,
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
                          Text(widget.user.first_name!),
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
                          Text(widget.user.last_name!),
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
                          Text(widget.user.birth_date
                              .toString()
                              .substring(0, 11)),
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
                                onPressed: () {},
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
                            child: Text(widget.user.phone_number.toString()),
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
                                        builder: (context) => ViewProfileCiud(
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
                          margin: EdgeInsets.only(left: 10),
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(widget.user.address_1!))),
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
                                  ? '${_user.contact_last_name} ${_user.contact_first_name}'
                                  : '${widget.user.contact_last_name} ${widget.user.contact_first_name}'))),
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
