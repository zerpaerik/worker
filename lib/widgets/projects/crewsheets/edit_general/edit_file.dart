import 'dart:typed_data';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/providers/workday.dart';
import 'package:worker/providers/crew.dart';
import 'package:worker/widgets/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

import '../../../../model/user.dart';
import '../../../widgets.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../contract_list.dart';

class EditCrewFileReport1 extends StatefulWidget {
  static const routeName = '/new-workday';
  Map<String, dynamic>? project;
  Map<String, dynamic>? report;

  EditCrewFileReport1({this.project, this.report});

  @override
  _EditCrewFileReport1State createState() =>
      _EditCrewFileReport1State(project, report);
}

class _EditCrewFileReport1State extends State<EditCrewFileReport1> {
  User? user;
  int? workday;
  Map<String, dynamic>? project;
  Map<String, dynamic>? report;
  _EditCrewFileReport1State(this.project, this.report);

  // ignore: unused_field
  int _selectedIndex = 4;
  bool yes_offer = false;
  int? selectedRadio;
  int? selectedRadio1;
  int? selectedRadio2;
  int? selectedRadio3;
  int? selectedRadio4;
  int? selectedRadio5;
  int? selectedRadio6;
  int? selectedRadio7;
  int? selectedRadio8;
  int? selectedRadio9;
  int? selectedRadio10;

  DateTime? hourClock; // init workday
  DateTime? hourClock1; // fin workday
  DateTime? hourClock2; // init lunch
  DateTime? hourClock3; // fin lunch
  DateTime? hourClock4; // init standby
  DateTime? hourClock5; // fin standby
  DateTime? hourClock6; // init travel
  DateTime? hourClock7; // fin travel
  DateTime? hourClock8; // init return
  DateTime? hourClock9; // fin return
  String? durationLunch;
  String? durationStandBy;
  String? durationTravel;
  String? durationReturn;
  String? comments;
  var drivers;
  final _form = GlobalKey<FormState>();
  List data = [];

  String? questions;
  var image;
  List imageArray = [];
  bool isLoading = false;
  bool _viewW = false;
  var rows = [];
  List results = [];
  String query = '';
  TextEditingController? tc;
  int _currentStep = 0;
  String? entry;
  String? departure;
  DateTime? start_time; // fin return
  DateTime? end_time;
  XFile? _documentPhoto;

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  getContract() async {
    SharedPreferences contract = await SharedPreferences.getInstance();
    //Return String
    int? intValue = contract.getInt('intValue');
    return intValue;
  }

  Future<void> _takeGallery() async {
    // ignore: deprecated_member_use
    final imageFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (imageFile == null) {
      return;
    }
    setState(() {
      _documentPhoto = imageFile;
    });
    print('result file');
    print(_documentPhoto);

    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    // ignore: unused_local_variable
    //final savedImage = await imageFile.copy('${appDir.path}/$fileName');
    final savedImage = await imageFile.saveTo('${appDir.path}/$fileName');
  }

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
    });
    print('se fue');
    try {
      Provider.of<CrewProvider>(context, listen: false)
          .uploadPhoto(
        _documentPhoto!,
        widget.report!['id'],
      )
          .then((response) {
        setState(() {
          isLoading = false;
        });
        print('response upload');
        print(response);
        if (response['status'] == '200') {
          print('updated fino');
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ContractList(location: widget.project)),
          );
        } else {
          setState(() {
            isLoading = false;
          });
          //_showErrorDialog();
          //_showErrorDialog('Verifique la información');
        }
      });
    } catch (error) {}
    /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePartOblig2()),
          );*/
  }

  Future<ImageProvider<Object>> xFileToImage(XFile xFile) async {
    final Uint8List bytes = await xFile.readAsBytes();
    return Image.memory(bytes).image;
  }

  @override
  void initState() {
    tc = TextEditingController();
    selectedRadio = 0;
    selectedRadio1 = 0;
    selectedRadio2 = 0;
    selectedRadio3 = 0;
    selectedRadio4 = 0;
    selectedRadio5 = 0;
    selectedRadio6 = 0;
    selectedRadio7 = 0;
    selectedRadio8 = 0;
    selectedRadio9 = 0;
    selectedRadio10 = 0;
    start_time = DateTime.parse(DateTime.now().toString());
    end_time = DateTime.parse(DateTime.now().toString());
    print('datos de crewsheet');
    print(widget.project);
    print(widget.report);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateFormat format = DateFormat("yyyy-MM-dd");
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SingleChildScrollView(
          child: Form(
        key: _form,
        child: Column(
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
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
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
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Subir imagen',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: HexColor('EA6012')),
                  ),
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Container(
              margin: EdgeInsets.only(left: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                    DateFormat("MMMM d yyyy")
                        .format(DateTime.parse(
                            widget.report!['workday_entry_time']))
                        .toString(),
                    style: TextStyle(
                        fontSize: 15,
                        color: HexColor('EA6012'),
                        fontWeight: FontWeight.bold)),
              ),
            ),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text('${l10n.hours}: ',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(widget.report!['worked_hours'].toString(),
                        style: TextStyle(
                            fontSize: 15,
                            color: HexColor('EA6012'),
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 30),
                  child: const Align(
                    alignment: Alignment.topLeft,
                    child: Text('Supervisor' + ': ',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(widget.report!['supervisor'].toString(),
                        style: TextStyle(
                            fontSize: 15,
                            color: HexColor('EA6012'),
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
                                child: Text('Imagen',
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: HexColor('EA6012'))),
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
                                    Icons.upload_file,
                                    color: HexColor('EA6012'),
                                  ),
                                  onPressed: () async {
                                    _takeGallery();
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
                                child: _documentPhoto != null
                                    ? Text(
                                        'Imagen cargada',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : Text(
                                        'No hay imagen',
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold),
                                      ))),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01),
                      ],
                    ))),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.23,
            ),
            Container(
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(right: 30),
              //width: MediaQuery.of(context).size.width * 0.70,
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: _documentPhoto != null
                          ? () {
                              _submit();
                            }
                          : null,
                      child: Text(
                        l10n.save,
                        style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      )),
    );
  }

  // ignore: unused_element
}
