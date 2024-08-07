import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:worker/providers/workday.dart';
import 'package:worker/widgets/workday-report/new/new1sj.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets.dart';
import '../../model/workday.dart';
import 'package:provider/provider.dart';

class InitWorkdayReportSJ extends StatefulWidget {
  Map<String, dynamic>? contract;

  InitWorkdayReportSJ({this.contract});

  @override
  _InitWorkdayReportSJState createState() =>
      _InitWorkdayReportSJState(contract!);
}

class _InitWorkdayReportSJState extends State<InitWorkdayReportSJ> {
  Map<String, dynamic> contract;
  _InitWorkdayReportSJState(this.contract);
  bool isLoading = false;

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
    });
    print('se fue');
    try {
      Provider.of<WorkDay>(context, listen: false)
          .addWorkdayReportSJ()
          .then((response) {
        setState(() {
          isLoading = false;
        });
        if (response['status'] == '201') {
          /*  Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewWorkdayReportSJ1(
                      report: response['report'],
                      contract: widget.contract,
                    )),
          );*/

          print('creo el reporte sin jornada');
        } else {
          setState(() {
            isLoading = false;
          });
          // _showErrorDialog();
          //_showErrorDialog('Verifique la información');
        }
      });
    } catch (error) {}
    /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePartOblig2()),
          );*/
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
        body: Center(
            child: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            HexColor('FE7E1F'),
            HexColor('F57E07'),
            HexColor('F8AF04'),
            HexColor('F5AE07'),
            HexColor('FD821E'),
          ])),
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
                        color: Colors.white,
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
                        color: Colors.white,
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
            height: MediaQuery.of(context).size.height * 0.10,
          ),
          Container(
              margin: EdgeInsets.only(left: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  'assets/002-data.png',
                  color: Colors.white,
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
                  l10n.daily_report_without,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 38,
                      color: Colors.white),
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
                  l10n.toregister_report_without,
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
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
                      l10n.accept,
                      style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: HexColor('EA6012')),
                    ),
                  ),
          ),
        ],
      ),
    )));
  }
}
