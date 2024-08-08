import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/providers/workday.dart';
import 'package:worker/providers/crew.dart';
import 'package:worker/widgets/projects/project_list.dart';
import 'package:worker/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

import '../../../model/user.dart';
import '../../widgets.dart';
import '../contract_list.dart';

class NewCresheet5 extends StatefulWidget {
  static const routeName = '/new-workday5';
  final int? workday;
  Map<String, dynamic>? contract;
  Map<String, dynamic>? location;

  NewCresheet5({@required this.workday, this.contract, this.location});

  @override
  _NewCresheet5State createState() =>
      _NewCresheet5State(workday, contract, location);
}

class _NewCresheet5State extends State<NewCresheet5> {
  User? user;
  int? workday;
  int? report;
  Map<String, dynamic>? contract;
  Map<String, dynamic>? location;

  _NewCresheet5State(this.workday, this.contract, this.location);

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

  var image;
  List imageArray = [];
  bool isLoading = false;
  bool _viewW = false;
  var rows = [];
  List results = [];
  String query = '';
  TextEditingController? tc;
  int _currentStep = 0;

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        titleTextStyle: TextStyle(
            color: HexColor('373737'),
            fontFamily: 'OpenSansRegular',
            fontWeight: FontWeight.bold,
            fontSize: 20),
        actions: <Widget>[
          TextButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
    });
    print('se fue5');
    print(comments);
    try {
      Provider.of<CrewProvider>(context, listen: false)
          .addWorkdayReport(widget.workday, widget.contract, comments)
          .then((response) {
        setState(() {
          isLoading = false;
        });
        if (response == '201') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ContractList(
                      location: widget.location,
                    )),
          );
        } else {
          setState(() {
            isLoading = false;
          });
          _showErrorDialog('Verifique los datos.');
        }
      });
    } catch (error) {}
    /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePartOblig2()),
          );*/
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
                    margin: EdgeInsets.only(left: 20),
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
                    margin: EdgeInsets.only(right: 20),
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
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            Container(
                margin: EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    'assets/002-data.png',
                    color: HexColor('EA6012'),
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
                    l10n.wr_16,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: HexColor('EA6012')),
                  ),
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: TextField(
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.done,
                maxLines: null,
                decoration: InputDecoration(
                    labelText: l10n.description,
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 1, color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 1, color: Colors.orange),
                      borderRadius: BorderRadius.circular(5),
                    )),
                onChanged: (value) {
                  setState(() {
                    comments = value;
                  });
                },
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
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
                      onPressed: _submit,
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
