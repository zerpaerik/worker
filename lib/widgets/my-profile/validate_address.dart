import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:worker/model/user.dart';
import '../../providers/auth.dart';
import 'info-personal/part_oblig2.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ValidateAddressSS extends StatefulWidget {
  final User user;

  Map<String, dynamic> data;
  ValidateAddressSS({required this.data, required this.user});

  @override
  _ValidateAddressSSState createState() => _ValidateAddressSSState(data, user);
}

class _ValidateAddressSSState extends State<ValidateAddressSS> {
  late Map<String, dynamic> data;
  late User user;
  _ValidateAddressSSState(data, user);

  late int selectedRadio1;

  setSelectedRadio1(int val) {
    setState(() {
      selectedRadio1 = val;
    });
  }

  Future<dynamic> _updateAddress() async {
    try {
      await Provider.of<Auth>(context, listen: false)
          .updateAddress(this.widget.data)
          .then((response) {
        setState(() {});

        if (response == '200') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ViewProfileOblig2(user: this.widget.user)),
          );
        }
        //
      });
    } catch (error) {}
  }

  @override
  void initState() {
    selectedRadio1 = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      // mainAxisSize: MainAxisSize.,
      children: <Widget>[
        SizedBox(
          height: 30,
        ),
        Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          alignment: Alignment.topLeft,
          child: Text(l10n.address_verify,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.left),
        ),
        SizedBox(
          height: 10,
        ),
        if (this.widget.data['is_valid'].toString() == 'S') ...[
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            alignment: Alignment.topLeft,
            child: Text(l10n.address_input,
                style: TextStyle(
                  // fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.left),
          ),
          Row(children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10),
              child: Radio(
                value: 1,
                groupValue: selectedRadio1,
                activeColor: HexColor('EA6012'),
                onChanged: (val) {
                  setSelectedRadio1(val!);
                },
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  // margin: EdgeInsets.only(right: 40),
                  child: Text(this.widget.data['address_1'],
                      //  maxLines: 2,
                      // overflow: TextOverflow.ellipsis,
                      //textDirection: TextDirection.rtl,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 20)),
                ),
                Container(
                  // margin: EdgeInsets.only(right: 40),
                  child: Text(
                      this.widget.data['city'] +
                          ' ' +
                          this.widget.data['state'] +
                          ' ' +
                          this.widget.data['zip_code'],
                      //  maxLines: 2,
                      // overflow: TextOverflow.ellipsis,
                      //textDirection: TextDirection.rtl,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 20)),
                ),
              ],
            )
          ]),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            alignment: Alignment.topLeft,
            child: Text(l10n.address_suggested,
                style: TextStyle(
                  // fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.left),
          ),
          Row(children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10),
              child: Radio(
                value: 2,
                groupValue: selectedRadio1,
                activeColor: HexColor('EA6012'),
                onChanged: (val) {
                  setSelectedRadio1(val!);
                },
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  // margin: EdgeInsets.only(right: 40),
                  child: Text(this.widget.data['candidate_1']['delivery_line'],
                      //  maxLines: 2,
                      // overflow: TextOverflow.ellipsis,
                      //textDirection: TextDirection.rtl,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 20)),
                ),
                Container(
                  // margin: EdgeInsets.only(right: 40),
                  child: Text(this.widget.data['candidate_1']['last_line'],
                      //  maxLines: 2,
                      // overflow: TextOverflow.ellipsis,
                      //textDirection: TextDirection.rtl,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ]),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            alignment: Alignment.topLeft,
            child: Text(l10n.address_oblig,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
                textAlign: TextAlign.left),
          ),
        ],
        if (this.widget.data['is_valid'].toString() == 'N') ...[
          Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: Text(l10n.error_address,
                style: TextStyle(
                  // fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.left),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
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
                        style: OutlinedButton.styleFrom(
                          side:
                              BorderSide(width: 5.0, color: HexColor('EA6012')),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                        ),
                        //onPressed: () => select("English"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },

                        child: Text(
                          l10n.editd,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: HexColor('EA6012')),
                        ),
                      ),
                    )),
              ),
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
                        onPressed: () {
                          if (selectedRadio1 != 0) {
                            Navigator.of(context).pop();
                          }
                          //_updateAddress();
                        },
                        style: OutlinedButton.styleFrom(
                          side:
                              BorderSide(width: 5.0, color: HexColor('EA6012')),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                        ),
                        child: Text(
                          l10n.continues,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: HexColor('EA6012')),
                        ),
                      ),
                    )),
              ),
            ],
          )
        ],
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
        ),
        if (this.widget.data['is_valid'].toString() == 'S') ...[
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
                        //onPressed: () => select("English"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side:
                              BorderSide(width: 5.0, color: HexColor('EA6012')),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                        ),
                        child: Text(
                          l10n.editd,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: HexColor('EA6012')),
                        ),
                      ),
                    )),
              ),
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
                        onPressed: () {
                          if (selectedRadio1 != 0) {
                            _updateAddress();
                          } else {
                            print('debes seleccionar una dirección');
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side:
                              BorderSide(width: 5.0, color: HexColor('EA6012')),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                        ),
                        child: Text(
                          l10n.continues,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: HexColor('EA6012')),
                        ),
                      ),
                    )),
              ),
            ],
          )
        ],
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
