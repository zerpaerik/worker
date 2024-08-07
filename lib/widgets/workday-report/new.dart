import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/providers/workday.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:worker/providers/url_constants.dart';

import '../../model/user.dart';
import '../dashboard/appbar.dart';
import '../dashboard/menu_lat.dart';
import '../widgets.dart';
import 'base.dart';

class NewWorkdayReport extends StatefulWidget {
  static const routeName = '/new-workday';
  final User user;
  final int workday;

  NewWorkdayReport({required this.user, required this.workday});

  @override
  _NewWorkdayReportState createState() => _NewWorkdayReportState(user, workday);
}

class _NewWorkdayReportState extends State<NewWorkdayReport> {
  User user;
  int workday;
  _NewWorkdayReportState(this.user, this.workday);

  // ignore: unused_field
  int? _selectedIndex = 4;
  bool? yes_offer = false;
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
  List _workers = [];
  List? _driversWork = [];
  List _driversWorkInfo = [];
  var image;
  List imageArray = [];
  bool isLoading = false;
  bool _viewW = false;
  var rows = [];
  List results = [];
  String query = '';
  TextEditingController? tc;
  int _currentStep = 0;

  _openGallery() async {
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
    imageArray.add(image);
    setState(() {
      imageArray;
    });
    print('desde galer');
  }

  _openCamera() async {
    image = await ImagePicker().pickImage(source: ImageSource.camera);
    imageArray.add(image);
    setState(() {
      imageArray;
    });
    print('desde cam');
  }

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

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  setSelectedRadio1(int val) {
    setState(() {
      selectedRadio1 = val;
    });
  }

  setSelectedRadio2(int val) {
    setState(() {
      selectedRadio2 = val;
    });
  }

  setSelectedRadio3(int val) {
    setState(() {
      selectedRadio3 = val;
    });
  }

  setSelectedRadio4(int val) {
    setState(() {
      selectedRadio4 = val;
    });
  }

  setSelectedRadio5(int val) {
    setState(() {
      selectedRadio5 = val;
    });
  }

  setSelectedRadio6(int val) {
    setState(() {
      selectedRadio6 = val;
    });
  }

  setSelectedRadio7(int val) {
    setState(() {
      selectedRadio7 = val;
    });
  }

  setSelectedRadio8(int val) {
    setState(() {
      selectedRadio8 = val;
    });
  }

  setSelectedRadio9(int val) {
    setState(() {
      selectedRadio9 = val;
    });
  }

  setSelectedRadio10(int val) {
    setState(() {
      selectedRadio10 = val;
    });
  }

  Future<dynamic> getSWData() async {
    String token = await getToken();
    int contract = await getContract();
    var res = await http.get(
        Uri.parse('$urlServices/api/v-1/contract/$contract/list-drivers'),
        headers: {
          "Authorization": "Token 4ead92aa67e22337c35db38e019437eba1fe4ab5"
        });
    var resBody = json.decode(res.body);

    setState(() {
      _workers = resBody;
    });

    return _workers;
  }

  Future<dynamic> getSWData1() async {
    String token = await getToken();
    int contract = await getContract();
    var res = await http.get(
        Uri.parse(
            '$urlServices/api/v-1/contract/$contract/list-workers-accepted'),
        headers: {
          "Authorization": "Token 4ead92aa67e22337c35db38e019437eba1fe4ab5"
        });
    var resBody = json.decode(res.body);

    setState(() {
      rows = resBody;
    });

    return rows;
  }

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
    });
    print('se fue');
    try {
      Provider.of<WorkDay>(context, listen: false)
          .addWorkdayReport(
              widget.workday,
              hourClock,
              hourClock1,
              hourClock2,
              hourClock3,
              durationLunch,
              _driversWork,
              hourClock4,
              hourClock4,
              durationStandBy,
              hourClock4,
              hourClock5,
              durationTravel,
              hourClock6,
              hourClock7,
              durationReturn,
              comments,
              imageArray)
          .then((response) {
        setState(() {
          // isLoading = false;
        });
        if (response == '201') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WorkDayPage(
                      user: user,
                      workday: widget.workday,
                    )),
          );
        } else {
          //_showErrorDialog('Verifique la información');
        }
      });
    } catch (error) {}
    /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePartOblig2()),
          );*/
  }

  void _onWorkerSelected(
      bool selected, worker_id, worker_name, worker_lastname, worker_btnid) {
    if (selected == true) {
      setState(() {
        _driversWork!.add(worker_id);
        _driversWorkInfo
            .add(worker_name + ' ' + worker_lastname + ' ' + worker_btnid);
        print(_driversWorkInfo);
      });
    } else {
      setState(() {
        _driversWork!.remove(worker_id);
        _driversWorkInfo
            .remove(worker_name + ' ' + worker_lastname + ' ' + worker_btnid);
        print(_driversWorkInfo);
      });
    }
  }

  @override
  void initState() {
    tc = TextEditingController();
    _driversWork = [];
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
    getSWData();
    getSWData1();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
        appBar: AppBar(
          elevation: 2.0,
          backgroundColor: Colors.white,
          centerTitle: true,
          automaticallyImplyLeading: false,
          iconTheme: IconThemeData(
            color: HexColor('EA6012'),
          ),
          title: Image.asset(
            "assets/homelogo.png",
            width: 120,
          ),
        ),
        // ignore: missing_required_param
        /* endDrawer: MenuLateral(
          user: user,
        ),*/
        body: SingleChildScrollView(
            child: Form(
          key: _form,
          child: Stepper(
            steps: _mySteps(),
            currentStep: _currentStep,
            onStepTapped: (step) {
              setState(() {
                _currentStep = step;
              });
            },
            onStepContinue: () {
              setState(() {
                if (_currentStep < _mySteps().length - 1) {
                  _currentStep = _currentStep + 1;
                } else {
                  //Logic to check if everything is completed
                  print('Completed, check fields.');
                }
              });
            },
            onStepCancel: () {
              setState(() {
                if (_currentStep > 0) {
                  _currentStep = _currentStep - 1;
                } else {
                  _currentStep = 0;
                }
              });
            },
          ),
        )),
        bottomNavigationBar: AppBarButton(
          rol: '',
          noti: false,
          user: user,
          selectIndex: 0,
        ));
  }

  void setResults(String query) {
    results = rows
        .where((elem) =>
            elem['first_name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            elem['btn_id']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();
  }

  List<Step> _mySteps() {
    List<Step> _steps = [
      Step(
        title: Text('Paso 1'),
        content: TextField(),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: Text('Paso 2'),
        content: TextField(),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: Text('Paso 3'),
        content: TextField(),
        isActive: _currentStep >= 2,
      )
    ];
    return _steps;
  }

  // ignore: unused_element
}
