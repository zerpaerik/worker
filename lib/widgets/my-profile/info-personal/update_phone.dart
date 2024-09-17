import 'package:worker/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'dart:io';

import '../../../model/user.dart';
import '../../../providers/auth.dart';
import '../../dashboard/index.dart';
import 'part_oblig.dart';

class UpdatePhone extends StatefulWidget {
  static const routeName = '/view-my-profile-contact';

  final User user;

  UpdatePhone({required this.user});

  @override
  _UpdatePhoneState createState() => new _UpdatePhoneState(user);
}

class _UpdatePhoneState extends State<UpdatePhone> {
  User user;
  _UpdatePhoneState(this.user);

  // ignore: unused_field
  // ignore: unused_field
  File? _pickedImage;

  final _priceFocusNode = FocusNode();

  final _form = GlobalKey<FormState>();

  late String phone = '';

  // ignore: unused_field
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Auth>(context, listen: false)
          .updateProfilePhone(phone, widget.user)
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                          Icons.close,
                          color: HexColor('EA6012'),
                        ),
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
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Container(
                margin: EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    'assets/call.png',
                    width: 70,
                  ),
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    l10n.phone_number,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: HexColor('EA6012')),
                  ),
                )),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: TextFormField(
                  initialValue: this.widget.user.phone_number,
                  decoration: InputDecoration(
                      labelText: l10n.phone,
                      labelStyle:
                          TextStyle(fontSize: 18, color: HexColor('EA6012'))),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.phone,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_priceFocusNode);
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Es obligatorio!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    setState(() {
                      phone = value!;
                    });
                    //_editedUser = User(phone_number: value);
                  },
                  onChanged: (value) {
                    setState(() {
                      phone = value;
                    });
                    //_editedUser = User(phone_number: value);
                  },
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.40,
            ),
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
                      onPressed: _saveForm,
                      child: Text(
                        l10n.accept,
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
