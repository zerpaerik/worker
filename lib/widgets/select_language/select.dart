// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../local/service.dart';
import '../../model/config.dart';
import '../login/preview.dart';

class SelectLang extends StatefulWidget {
  @override
  _SelectLangState createState() => new _SelectLangState();
}

class _SelectLangState extends State<SelectLang> {
  late String idioma;

  late double maxtop;
  bool es = false;
  bool en = false;

  @override
  void initState() {
    super.initState();
    // application.onLocaleChanged = onLocaleChange;
    // onLocaleChange(Locale(languagesMap["Español"]));
  }

  void onLocaleChange(Locale locale) async {
    setState(() {
      //AppLocali.load(locale);
    });
  }

  Future<void> select(String language) async {
    print("dd " + language);

    SharedPreferences lang = await SharedPreferences.getInstance();
    lang.setString('stringValue', 'label');

    /* Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginNew()),
    );*/
  }

  void createTodo(lang) async {
    int count = /*await RepositoryServiceTodo.todosCount()*/ 0;
    final todo = Config(count, lang, '', '', '', '', '', '', '', '', '', '', '',
        '', '', '', '');
    await RepositoryServiceTodo.addTodo(todo);
    await RepositoryServiceTodo.addContract();
    await RepositoryServiceTodo.addWorkdayOnline();

    setState(() {
      // future = RepositoryServiceTodo.getAllTodos();
    });
    print(todo.id);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    /*  String _titleH = AppTranslations.of(context).text("select_lang");
    SizeConfig().init(context);
    var screenSize = MediaQuery.of(context).size;
    if (screenSize.height > 800) {
      maxtop = 80;
    } else {
      maxtop = 40;
    }*/
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF02BB9F),
        primaryColorDark: const Color(0xFF167F67),
        // accentColor: const Color(0xFF167F67),
      ),
      home: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Container(
            child: Form(
              //  key: _formKey,
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.23,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          //color: HexColor('EA6012'),
                          gradient: LinearGradient(
                            begin: Alignment.bottomRight,
                            end: Alignment.topLeft,
                            colors: [
                              HexColor('FBB03B'),
                              HexColor('EF6826'),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(25),
                              bottomRight: Radius.circular(25))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.12,
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 20.0),
                              alignment: Alignment.topLeft,
                              child: const Text('Language',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 35,
                                      color: Colors.white)))
                        ],
                      ),
                    ),
                    Container(
                        //height: MediaQuery.of(context).size.height,
                        //width: double.infinity,
                        child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 130.0),
                          child: Form(
                              //key: formKey,
                              child: Container(
                            padding: EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 1.0),
                                      width: double.infinity,
                                      child: en
                                          ? OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                    width: 5.0,
                                                    color: HexColor('EA6012')),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0)),
                                              ),
                                              onPressed: () {},
                                              child: Text(
                                                'English',
                                                style: TextStyle(
                                                  color: HexColor('EA6012'),
                                                  letterSpacing: 1,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      'OpenSans-Regular',
                                                ),
                                              ),
                                            )
                                          : OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                    width: 5.0,
                                                    color: Colors.grey),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0)),
                                              ),

                                              //onPressed: () => select("English"),
                                              onPressed: () {
                                                setState(() {
                                                  en = true;
                                                  es = false;
                                                });
                                                createTodo("English");
                                                select("English");
                                              },
                                              child: Text(
                                                'English',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  letterSpacing: 1,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      'OpenSans-Regular',
                                                ),
                                              ),
                                            ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 1.0),
                                      width: double.infinity,
                                      child: es
                                          ? OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                    width: 5.0,
                                                    color: HexColor('EA6012')),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0)),
                                              ),
                                              //  onPressed: () => select("Español"),
                                              onPressed: () {
                                                setState(() {
                                                  es = true;
                                                  en = false;
                                                });
                                              },

                                              child: Text(
                                                'Español',
                                                style: TextStyle(
                                                  color: HexColor('EA6012'),
                                                  letterSpacing: 1,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      'OpenSans-Regular',
                                                ),
                                              ),
                                            )
                                          : OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                    width: 5.0,
                                                    color: Colors.grey),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0)),
                                              ),
                                              //  onPressed: () => select("Español"),
                                              onPressed: () {
                                                setState(() {
                                                  es = true;
                                                  en = false;
                                                });
                                                createTodo("Español");
                                                select("Español");
                                              },

                                              child: const Text(
                                                'Español',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  letterSpacing: 1,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      'OpenSans-Regular',
                                                ),
                                              ),
                                            ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.15,
                                    ),
                                    if (en || es) ...[
                                      Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 1.0),
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      HexColor('EA6012')),
                                            ),
                                            // color: HexColor('EA6012'),
                                            //borderSide: BorderSide(color: HexColor('EA6012')),
                                            //onPressed: () => select("English"),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const PreviewAccount()),
                                              );
                                              // createTodo("Español");
                                              // select("Español");
                                            },
                                            //padding: EdgeInsets.all(15),
                                            /* shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),*/

                                            child: const Text(
                                              'Ok',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17,
                                                  color: Colors.white),
                                            ),
                                          )),
                                    ],
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                        ),
                      ],
                    )),
                  ])
                ],
              )),
            ),
          )),
    );
  }
}
