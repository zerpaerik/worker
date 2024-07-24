import 'dart:io';
import 'dart:convert';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:signature/signature.dart';
import 'package:worker/model/offer.dart';
import 'package:worker/providers/offer_job.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:worker/providers/url_constants.dart';

import 'dart:async';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
//
import '../../../model/user.dart';
import '../../../model/country.dart';
import '../../../model/states.dart';
import '../../../model/city.dart';
import '../../../providers/offer_job.dart';
import '../../widgets.dart';
import 'added_sections.dart';
import 'list.dart';
import 'sign_postulation.dart';

class PostulationPage extends StatefulWidget {
  static const routeName = '/postulation';
  final User user;
  final String offer;
  final Map<String, dynamic> detail;

  PostulationPage(
      {required this.user, required this.offer, required this.detail});

  @override
  _PostulationPageState createState() =>
      _PostulationPageState(user, offer, detail);
}

class _PostulationPageState extends State<PostulationPage> {
  late User user;
  late String offer;
  late Map<String, dynamic> detail = {};

  _PostulationPageState(this.user, this.offer, this.detail);
  late bool address = false;
  late bool sign = false;
  // ignore: non_constant_identifier_names
  late bool other_meeting = false;
  late String _valEdo;
  late bool _roleDriverFlag = false;
  late bool _arriveMeansFlag = false;
  late bool edo = false;
  late String _valMeeting;
  late String _valCond;
  late bool meetingV = false;
  late String _valAdd2;
  List _listAdd2 = ['Agregar'];
  late List _listEdo = ['Si', 'No'];
  late List meeting = [];
  // ignore: unused_field
  late List _listCountry = ["EEUU", 'Mexico'];
  // ignore: unused_field
  late List _listState = ['Florida', 'Houston'];
  // ignore: unused_field
  late List _listCity = ['Manhattan', 'BeverlyHills'];
  late List dataStates = [];
  late List dataCitys = [];
  var _myselection;
  var _myselection2;
  late int stateselect;
  late int cityselect;
  late File signPostulation;
  final _form = GlobalKey<FormState>();
  late GlobalKey<_PostulationPageState> signatureKey = GlobalKey();
  static const directoryName = 'Signature';
  late var image;
  late var _isLoading = false;
  late final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.blue,
  );
  late var _dateOffer = Offer(
      is_accepted: false,
      accepted_contracting_conditions: false,
      arrives_on_his_own: false,
      departure_location: '',
      country: 0,
      state: 0,
      city: 0,
      address: '',
      wants_to_be_driver: false,
      signature: File('assets'));

  // LIST COUNTRYS
  // List<Country> _countrys = Country.getCountrys();
  late List<DropdownMenuItem<Country>> _dropdownMenuItemsC;
  late Country _selectedCountry;

  // LIST STATES
  late List<States> _states = States.getStates();
  late List<DropdownMenuItem<States>> _dropdownMenuItemsS;
  late States _selectedState;

  // LIST CITYS
  late List<City> _citys = City.getCitys();
  late List<DropdownMenuItem<City>> _dropdownMenuItemsCI;
  late City _selectedCity;

  late int _selectedIndex = 4;

  // ITEMS DROPDOWN COUNTRY

  List<DropdownMenuItem<Country>> buildDropdownMenuItems(List countrys) {
    List<DropdownMenuItem<Country>> items = [];
    for (Country country in countrys) {
      items.add(
        DropdownMenuItem(
          value: country,
          child: Text(country.name),
        ),
      );
    }
    return items;
  }

  // ITEMS DROPDOWN STATE

  List<DropdownMenuItem<States>> buildDropdownMenuItemsS(List states) {
    List<DropdownMenuItem<States>> items = [];
    for (States state in states) {
      items.add(
        DropdownMenuItem(
          value: state,
          child: Text(state.name),
        ),
      );
    }
    return items;
  }

  // ITEMS DROPDOWN CITY

  List<DropdownMenuItem<City>> buildDropdownMenuItemsC(List citys) {
    List<DropdownMenuItem<City>> items = [];
    for (City city in citys) {
      items.add(
        DropdownMenuItem(
          value: city,
          child: Text(city.name),
        ),
      );
    }
    return items;
  }

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  void _showSign() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        contentPadding: EdgeInsets.only(top: 10.0),
        content: Container(
          height: 270,
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 5.0,
              ),
              Column(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  Container(
                    child: Image.file(
                      signPostulation,
                      width: 400,
                    ) /*Image.network(user.profile_image
                          .toString()
                          .replaceAll('File: ', '')
                          .replaceAll("'", ""))*/
                    ,
                  )
                ],
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                    //color: myColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32.0),
                        bottomRight: Radius.circular(32.0)),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'Ok',
                      style: TextStyle(
                          color: HexColor('EA6012'),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _navigateSign(BuildContext context) async {
    // Navigator.push devuelve un Future que se completará después de que llamemos
    // Navigator.pop en la pantalla de selección!
    final result = await Navigator.push(
      context,
      // Crearemos la SelectionScreen en el siguiente paso!
      MaterialPageRoute(
          builder: (context) => SignPostulation(
                user: user,
              )),
    );

    print('es imagen');
    print(result);
    setState(() {
      signPostulation = result;
    });
  }

  Future<void> _saveForm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Provider.of<OfferJob>(context, listen: false)
          .applyOffer(_dateOffer, offer, _controller.toString(), meetingV,
              signPostulation)
          .then((response) {
        setState(() {
          _isLoading = false;
          // ignore: unused_local_variable
          String offer = response['id'].toString();
        });

        if (this.widget.detail['contract']['added_sections'].length == 0) {
          print('mp');
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => JobOfferPage(
                      user: user,
                    )),
          );
        } else {
          print('mpo');

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AAddedSectionsOffer(
                      user: widget.user,
                      sections: widget.detail['contract']['added_sections'][0]
                              ['description_text']
                          .toString(),
                      check: widget.detail['contract']['added_sections'][0]
                          ['checkbox_text'],
                    )),
          );
        }
      });
    } catch (error) {}
    /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePartOblig2()),
          );*/
  }

  Future<dynamic> getSWData() async {
    String token = await getToken();

    var res = await http.get(Uri.parse('$urlServices/api/v-1/address/state'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);

    setState(() {
      dataStates = resBody;
    });

    return "Sucess";
  }

  Future<dynamic> getSWData1(int state) async {
    String token = await getToken();

    var res = await http.get(
        Uri.parse('$urlServices/api/v-1/address/state/$state/city'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);

    setState(() {
      dataCitys = resBody;
    });

    return "Sucess";
  }

  @override
  void initState() {
    _controller.addListener(() => print("Value changed"));
    // _dropdownMenuItemsC = buildDropdownMenuItems(_countrys);
    _dropdownMenuItemsS = buildDropdownMenuItemsS(_states);
    _selectedState = _dropdownMenuItemsS[0].value!;
    _dropdownMenuItemsCI = buildDropdownMenuItemsC(_citys);
    _selectedCity = _dropdownMenuItemsCI[0].value!;
    this.getSWData();

    setState(() {
      meeting = this.widget.detail['contract']['starting_points'];
    });

    super.initState();
    AutoOrientation.portraitAutoMode();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    List _listEdo = [l10n.si, l10n.no];

    return Scaffold(
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
                    margin: EdgeInsets.only(left: 5),
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
                    margin: EdgeInsets.only(right: 10),
                    width: MediaQuery.of(context).size.width * 0.50,
                    child: Container(
                      child: Text(''),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(l10n.acceptance_offer,
                    style: TextStyle(
                        fontSize: 25,
                        color: HexColor('EA6012'),
                        fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            Container(
                margin: EdgeInsets.only(left: 32, right: 32),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(l10n.you_arrive,
                        style: TextStyle(
                          fontSize: 18,
                        )))),
            Container(
                margin: EdgeInsets.only(left: 32, right: 32),
                child: FormField(
                  builder: (state) {
                    return DropdownButton(
                      isExpanded: true,
                      iconEnabledColor: HexColor('EA6012'),
                      hint: Text(l10n.select,
                          style: TextStyle(
                            fontSize: 16,
                          )),
                      underline: Container(
                        height: 1,
                        color: Colors.grey,
                      ),
                      value: _valEdo,
                      items: _listEdo.map((value) {
                        return DropdownMenuItem(
                          child: Text(value,
                              style: TextStyle(
                                fontSize: 17,
                              )),
                          value: value,
                        );
                      }).toList(),
                      onChanged: (value) => setState(() {
                        _arriveMeansFlag = true;
                        //_valEdo = value;
                        if (_valEdo == 'Si') {
                          edo = true;
                        } else {
                          edo = false;
                        }
                        state.didChange(value);
                      }),
                    );
                    // ignore: dead_code
                    // ignore: unnecessary_statements
                    // ignore: dead_code
                    onSaved:
                    // ignore: unnecessary_statements
                    (value) {
                      _dateOffer = Offer(
                        is_accepted: address,
                        accepted_contracting_conditions: address,
                        arrives_on_his_own: edo,
                        departure_location: _valMeeting,
                        address: value,
                        wants_to_be_driver: meetingV,
                        country: 0,
                        state: 0,
                        city: 0,
                        signature: File('ass'),
                      );
                    };
                  },
                )),
            if (_valEdo == 'No') ...[
              if (meeting.length != 0) ...[
                Container(
                    margin: EdgeInsets.only(left: 32, right: 32),
                    child: DropdownButton(
                      value: _valMeeting,
                      iconEnabledColor: HexColor('EA6012'),
                      isExpanded: true,
                      items: meeting.map((item) {
                        return new DropdownMenuItem(
                            child: new Text(item['address']),
                            value: item['address']);
                      }).toList(),
                      onChanged: (newVal) {
                        setState(() {
                          //_valMeeting = newVal;
                        });
                        print(_valMeeting);
                      },
                      hint: Text(l10n.lugar_departure),
                    ))
              ],
              Row(children: <Widget>[
                Container(
                    margin: EdgeInsets.only(left: 17, right: 5),
                    child: Checkbox(
                      activeColor: HexColor('EA6012'),
                      value: other_meeting,
                      onChanged: (value) {
                        setState(() {
                          other_meeting = value!;
                          print(other_meeting);
                        });
                      },
                    )),
                Text(l10n.select_other_depa,
                    style: TextStyle(
                      fontSize: 17,
                    ))
              ])
            ],
            if (other_meeting) ...[
              Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: TextFormField(
                  decoration: InputDecoration(labelText: l10n.select_other),
                  onSaved: (value) {
                    _dateOffer = Offer(
                        is_accepted: address,
                        accepted_contracting_conditions: address,
                        arrives_on_his_own: edo,
                        departure_location: _valMeeting,
                        address: '',
                        wants_to_be_driver: meetingV,
                        city: 0,
                        state: 0,
                        country: 0,
                        signature: File('aase'));
                  },
                ),
              ),
            ],
            SizedBox(
              height: 10,
            ),
            Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(l10n.you_driver,
                        style: TextStyle(
                          fontSize: 18,
                        )))),
            Container(
                margin: EdgeInsets.only(left: 32, right: 32),
                child: FormField(
                  builder: (state) {
                    return DropdownButton(
                      isExpanded: true,
                      iconEnabledColor: HexColor('EA6012'),
                      hint: Text(l10n.select,
                          style: TextStyle(
                            fontSize: 17,
                          )),
                      underline: Container(
                        height: 1,
                        color: Colors.grey,
                      ),
                      value: _valCond,
                      items: _listEdo.map((value) {
                        return DropdownMenuItem(
                          child: Text(value),
                          value: value,
                        );
                      }).toList(),
                      onChanged: (value) => setState(() {
                        _roleDriverFlag = true;
                        //_valCond = value;
                        if (_valCond == 'Si') {
                          meetingV = true;
                        } else {
                          meetingV = false;
                        }
                        _dateOffer = Offer(
                            is_accepted: address,
                            accepted_contracting_conditions: address,
                            arrives_on_his_own: edo,
                            departure_location: _valMeeting,
                            address: _dateOffer.address,
                            wants_to_be_driver: meetingV,
                            city: 0,
                            country: 0,
                            state: 0,
                            signature: File('ass'));
                        state.didChange(value);
                      }),
                    );
                    // ignore: unnecessary_statements
                    // ignore: dead_code
                  },
                )),
            /*  Row(
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(left: 30),
                    child: Text(AppTranslations.of(context).text("sign_offer"),
                        style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                          fontSize: 17,
                        )))),
                Container(
                  //margin: EdgeInsets.only(left: 10),
                  child: IconButton(
                      icon: Icon(Icons.search, color: HexColor('EA6012')),
                      onPressed: () {
                        _navigateSign(context);
                      }),
                )
              ],
            ),*/
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Row(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(
                    left: 30,
                  ),
                  //  margin: EdgeInsets.only(left: 30),
                  //width: MediaQuery.of(context).size.width * 0.70,
                  child: ElevatedButton(
                    onPressed: () {
                      _navigateSign(context);
                    },
                    child: Text(
                      l10n.sign_offer,
                      style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white),
                    ),
                  ),
                ),
                if (signPostulation != null) ...[
                  Container(
                    margin: EdgeInsets.only(
                      left: 5,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                  )
                ],
              ],
            ),
            if (signPostulation != null) ...[
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(
                  left: 30,
                ),
                //  margin: EdgeInsets.only(left: 30),
                //width: MediaQuery.of(context).size.width * 0.70,
                child: ElevatedButton(
                  onPressed: () {
                    _showSign();
                  },
                  child: Text(
                    l10n.see_signature,
                    style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
            Row(children: <Widget>[
              Container(
                  margin: EdgeInsets.only(left: 17),
                  child: Checkbox(
                    activeColor: HexColor('EA6012'),
                    value: address,
                    onChanged: (value) async {
                      setState(() {
                        address = value!;
                        print(address);
                      });
                      _dateOffer = Offer(
                          is_accepted: address,
                          accepted_contracting_conditions: address,
                          arrives_on_his_own: edo,
                          departure_location: _valMeeting,
                          address: _dateOffer.address,
                          wants_to_be_driver: meetingV,
                          city: 0,
                          country: 0,
                          state: 0,
                          signature: File('ass'));
                    },
                  )),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              Container(
                margin: EdgeInsets.only(right: 20),
                child: Text(l10n.accept_conditions,
                    style: TextStyle(
                      fontSize: 18,
                    )),
              )
            ]),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.10,
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
                      onPressed: (address &&
                              signPostulation != null &&
                              _roleDriverFlag &&
                              _arriveMeansFlag)
                          ? _saveForm
                          : null,
                      child: Text(
                        l10n.apply,
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

  renderBenefits(benefitsO) {
    return Column(
        children: benefitsO
            .map<Widget>((ben) =>
                //Mostar items
                Container(
                    margin: EdgeInsets.only(left: 21, right: 21),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                          (ben['concept'] != null) ? ben['concept'] : '',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                    )))
            .toList());
  }

  Future<Null> showImage(BuildContext context) async {
    var pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);
    // Use plugin [path_provider] to export image to storage
    Directory? directory = await getExternalStorageDirectory();
    String path = directory!.path;
    print(path);
    await Directory('$path/$directoryName').create(recursive: true);
    File('$path/$directoryName/${formattedDate()}.png')
        .writeAsBytesSync(pngBytes.buffer.asInt8List());
  }

  String formattedDate() {
    DateTime dateTime = DateTime.now();
    String dateTimeString = 'Signature_' +
        dateTime.year.toString() +
        dateTime.month.toString() +
        dateTime.day.toString() +
        dateTime.hour.toString() +
        ':' +
        dateTime.minute.toString() +
        ':' +
        dateTime.second.toString() +
        ':' +
        dateTime.millisecond.toString() +
        ':' +
        dateTime.microsecond.toString();
    return dateTimeString;
  }
}
