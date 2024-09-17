import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:worker/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:io';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../model/gender.dart';
import '../../../model/user.dart';
import '../../../providers/auth.dart';
import '../../widgets.dart';
import 'part_oblig.dart';

class ViewProfileOblig2 extends StatefulWidget {
  static const routeName = '/view-my-profile2';

  final User user;

  ViewProfileOblig2({required this.user});

  @override
  _ViewProfileOblig2State createState() => new _ViewProfileOblig2State(user);
}

class _ViewProfileOblig2State extends State<ViewProfileOblig2> {
  late User user;
  _ViewProfileOblig2State(this.user);

  late String _valDoc = '';
  late String _valEdo = '';
  late String _valDocsSheet = '';
  late String _valDociSheet = '';
  late String _valDocI = '';
  late String _value = '';
  // ignore: unused_field
  late String _valDocN = '';
  // ignore: unused_field
  late File _pickedImage;
  late String _valBlood = '';
  late String _valRh = '';
  late String _valor = '';
  late DateTime _valExpire;
  late List _listDoc = ['SSN', 'ITIN'];
  late List _listDocI = ['Licencia de Conducir', 'StateId', 'Pasaporte'];
  late List _listEdo = ['Soltero(a)', 'Casado(a)', 'Divorciado(a)', 'Viudo(a)'];
  late List _listBlodd = ['A', 'B', 'AB', 'O'];
  late List _listRH = ['Positivo (+)', 'Negativo (-)', 'No lo se'];
  late String name = '';
  late String ape = '';
  late String phone = '';
  late String email = '';

  late final _priceFocusNode = FocusNode();
  late final _descriptionFocusNode = FocusNode();
  late final _imageUrlController = TextEditingController();
  late final _imageUrlFocusNode = FocusNode();
  late final _form = GlobalKey<FormState>();
  late final _form1 = GlobalKey<FormState>();
  late final _form2 = GlobalKey<FormState>();
  var _editedUser = User(
    id: 0,
    first_name: '',
    last_name: '',
    email: '',
    birth_date: DateTime.now(),
    country: 0,
    state: 0,
    city: 0,
    gender: '',
    address_1: '',
    address_2: '',
    city_name: '',
    birthplace: '',
    doc_expire_date: DateTime.now(),
    dependents_number: '',
    contact_first_name: '',
    contact_last_name: '',
    contact_phone: '',
    contact_email: '',
    speciality_or_degree: '',
    btn_id: '',
    tax_doc_file: null,
    state_name: '',
  );

  // ignore: unused_field
  late String _myActivity = '';
  // ignore: unused_field
  // ignore: unused_field
  late String _myActivityResult = '';

  // MASK SSN - ITIN
  var maskTextInputFormatter = MaskTextInputFormatter(
      mask: "###-##-####", filter: {"#": RegExp(r'[0-9]')});
  var maskTextInputFormatterItin = MaskTextInputFormatter(
      mask: "9##-##-####", filter: {"#": RegExp(r'[0-9]')});
  var maskTextInputFormatterID = MaskTextInputFormatter(
      mask: "#########", filter: {"#": RegExp(r'[0-9]')});
  // ignore: unused_field
  var _isLoading = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  String capitalize(String string) {
    if (string == null) {
      throw ArgumentError("string: $string");
    }

    if (string.isEmpty) {
      return string;
    }

    return string[0].toUpperCase() + string.substring(1);
  }

  @override
  void initState() {
    _myActivity = '';
    _value = '';
    _myActivityResult = '';
    super.initState();
  }

  List<DropdownMenuItem<Gender>> buildDropdownMenuItems(List genders) {
    List<DropdownMenuItem<Gender>> items = [];
    for (Gender gender in genders) {
      items.add(
        DropdownMenuItem(
          value: gender,
          child: Text(gender.name),
        ),
      );
    }
    return items;
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    setState(() {
      _isLoading = true;
    });
    try {
      Map<String, dynamic> data = {
        "name": name,
        "ape": ape,
        "phone": phone,
        "email": email,
      };
      await Provider.of<Auth>(context, listen: false)
          .updateProfile2(
              _editedUser, widget.user, data, name, ape, phone, email)
          .then((response) {
        setState(() {
          _isLoading = false;
        });
        if (response['status'] == '200') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewProfileOblig(
                      user: widget.user,
                    )),
          );
        } else {}
      });
    } catch (error) {}
  }

  void _selectImage(File pickedImage) {
    _pickedImage = pickedImage;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    _valEdo = 'Soltero(a)';
    _valBlood = 'A';
    _valRh = 'Positivo (+)';
    _valDocsSheet = '-';

    return Scaffold(
      //endDrawer: EndDrawer(),
      body: Form(
        key: _form,
        child: ListView(
          children: <Widget>[
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
                          Icons.cancel,
                          color: HexColor('EA6012'),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
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
                    'assets/contact.png',
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
                    l10n.emergency_contact,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: HexColor('EA6012')),
                  ),
                )),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: TextFormField(
                  initialValue: widget.user.contact_first_name == '0'
                      ? ''
                      : widget.user.contact_first_name,
                  decoration: InputDecoration(
                      labelText: l10n.key_first_name,
                      labelStyle:
                          TextStyle(fontSize: 18, color: HexColor('EA6012'))),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_priceFocusNode);
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Es obligatorio!';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                  onSaved: (value) {
                    setState(() {
                      name = value!;
                    });
                  },
                )),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: TextFormField(
                initialValue: this.widget.user.contact_last_name == '0'
                    ? ''
                    : this.widget.user.contact_last_name,
                decoration: InputDecoration(
                    labelText: l10n.key_last_name,
                    labelStyle:
                        TextStyle(fontSize: 18, color: HexColor('EA6012'))),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Es obligatorio!';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    ape = value;
                  });
                },
                onSaved: (value) {
                  setState(() {
                    ape = value!;
                  });
                  _editedUser.contact_last_name = value;

                  /*  _editedUser = User(
                      contact_first_name: _editedUser.contact_first_name,
                      contact_last_name: value,
                      contact_phone: _editedUser.contact_phone,
                      contact_email: _editedUser.contact_email,
                      dependents_number: _editedUser.dependents_number);*/
                },
              ),
            ),
            Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: TextFormField(
                  initialValue: this.widget.user.contact_phone == '0'
                      ? ''
                      : this.widget.user.contact_phone,
                  decoration: InputDecoration(
                      labelText: l10n.phone,
                      labelStyle:
                          TextStyle(fontSize: 18, color: HexColor('EA6012'))),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_priceFocusNode);
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Es obligatorio!';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      phone = value;
                    });
                  },
                  onSaved: (value) {
                    setState(() {
                      phone = value!;
                    });
                    _editedUser.contact_phone = value;
                  },
                )),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: TextFormField(
                initialValue: this.widget.user.contact_email == '0'
                    ? ''
                    : this.widget.user.contact_email,
                decoration: InputDecoration(
                    labelText: l10n.key_email,
                    labelStyle:
                        TextStyle(fontSize: 18, color: HexColor('EA6012'))),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Es obligatorio!';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
                onSaved: (value) {
                  setState(() {
                    email = value!;
                  });
                  _editedUser.contact_email = value;
                },
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.10,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
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
                        _saveForm();
                      },
                      child: Text(
                        l10n.update_next,
                        style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
