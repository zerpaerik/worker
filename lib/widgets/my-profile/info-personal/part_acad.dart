import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../model/user.dart';
import '../../../providers/auth.dart';
import '../../global.dart';
import '../../widgets.dart';

class ViewProfileAcad extends StatefulWidget {
  static const routeName = '/view-my-profile-acad';

  final User user;

  ViewProfileAcad({required this.user});

  @override
  _ViewProfileAcadState createState() => new _ViewProfileAcadState(user);
}

class _ViewProfileAcadState extends State<ViewProfileAcad> {
  final _form = GlobalKey<FormState>();

  late User user;
  _ViewProfileAcadState(this.user);
  late String _valNivel = '';
  late bool lislang = false;
  late bool dataNull = false;
  late bool other = false;
  late String complet;

  late String _valSp = '';

  late bool isData = false;

  late List<Map<String, dynamic>> dataLanguages = [];
  late List listLanguage = [];
  late List listLevel = [];
  late List myLannguages = [];
  late String selectedSpeciality = [] as String;

  late String selectedValue = ' ';
  late String selectedLevel = ' ';
  late String otherLang = ' ';

  late TextEditingController _nameController;
  late bool _isLoading = false;

  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();

  late String name = '';
  late String nameFile = '';

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showErrorInput(String message) {
    print(message);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Error!',
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
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

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<dynamic> getSWData() async {
    String token = await getToken();

    var res = await http.get(
        Uri.parse(ApiWebServer.server_name + '/api/v-1/user/my-languages'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(utf8.decode(res.bodyBytes));

    setState(() {
      myLannguages = resBody;
      if (myLannguages.length > 0) {
        isData = true;
        print('data');
      } else {
        isData = false;
        print('vacio');
      }
    });

    return "Sucess";
  }

  Future<void> _saveForm() async {
    setState(() {
      _isLoading = true;
    });
    /*try {
      await Provider.of<Auth>(context, listen: false)
          .updatePartAdic(_editedUser, this.widget.user)
          .then((response) {
        setState(() {
          _isLoading = false;
        });
        if (response['status'] == '200') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MyProfile(
                      user: this.widget.user,
                    )),
          );
        } else {}
      });
    } catch (error) {}*/
  }

  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push devuelve un Future que se completará después de que llamemos
    // Navigator.pop en la pantalla de selección!
    /* final result = await Navigator.push(
      context,
      // Crearemos la SelectionScreen en el siguiente paso!
      MaterialPageRoute(
          builder: (context) => AddLanguage(
                user: widget.user,
              )),
    );
    this.getSWData();*/
  }

  _navigateAndDisplaySelection1(BuildContext context, data) async {
    // Navigator.push devuelve un Future que se completará después de que llamemos
    // Navigator.pop en la pantalla de selección!
    /*final result = await Navigator.push(
      context,
      // Crearemos la SelectionScreen en el siguiente paso!
      MaterialPageRoute(
          builder: (context) => EditLanguage(
                user: widget.user,
                lang: data,
              )),
    );
    this.getSWData();*/
  }

  @override
  void initState() {
    if (this.widget.user.speciality_or_degree != null) {
      _valSp = widget.user.speciality_or_degree!;
    } else {
      _valSp = '';
    }

    if (this.widget.user.degree_levels != null) {
      _valNivel = widget.user.degree_levels!;
    } else {
      _valNivel = '';
    }
    super.initState();
    this.getSWData();
    dataLanguages = [];
    _nameController = TextEditingController();
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Estás Intentando Eliminar un Idioma'),
        content: Text('¿Estás seguro que deseas eliminarlo?'),
        titleTextStyle: TextStyle(
            color: HexColor('373737'),
            fontFamily: 'OpenSansRegular',
            fontWeight: FontWeight.bold,
            fontSize: 20),
        actions: <Widget>[
          TextButton(
            child: Text('No',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text(
              'Si',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    List _listNivel = [
      l10n.none,
      l10n.school,
      l10n.college,
      l10n.university,
      l10n.masters,
      l10n.doctorate
    ];

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
                child: Text(l10n.academic_data,
                    style: TextStyle(
                        fontSize: 25,
                        color: HexColor('EA6012'),
                        fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            if (this.widget.user.degree_levels != null) ...[
              Container(
                  margin: EdgeInsets.only(left: 30, right: 30),
                  child: TextFormField(
                    enabled: false,
                    initialValue: this.widget.user.degree_levels,
                    decoration: InputDecoration(labelText: l10n.level_study),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_priceFocusNode);
                    },
                    validator: (value) {
                      return null;
                    },
                    onSaved: (value) {},
                  )),
            ],
            if (this.widget.user.degree_levels == null) ...[
              Container(
                  width: 130,
                  margin: EdgeInsets.only(left: 30, right: 30),
                  child: FormField(
                    builder: (state) {
                      return DropdownButton(
                        isExpanded: true,
                        iconEnabledColor: HexColor('EA6012'),
                        hint: Text(l10n.select),
                        underline: Container(
                          height: 1,
                          color: Colors.grey,
                        ),
                        value: selectedSpeciality,
                        items: _listNivel.map((value) {
                          return DropdownMenuItem(
                            child: Text(value),
                            value: value,
                          );
                        }).toList(),
                        onChanged: (value) => setState(() {
                          //selectedSpeciality = value;
                          state.didChange(value);
                        }),
                      );
                    },
                  ))
            ],
            if (selectedSpeciality == 'School' ||
                selectedSpeciality == 'College' ||
                selectedSpeciality == 'University' ||
                selectedSpeciality == 'Masters' ||
                selectedSpeciality == 'Doctorate' ||
                selectedSpeciality == 'Escuela' ||
                selectedSpeciality == 'Tecnico' ||
                selectedSpeciality == 'Universitario' ||
                selectedSpeciality == 'Masters' ||
                selectedSpeciality == 'Doctorado' ||
                this.widget.user.degree_levels == 'Escuela' ||
                this.widget.user.degree_levels == 'Tecnico' ||
                this.widget.user.degree_levels == 'Universitario' ||
                this.widget.user.degree_levels == 'Maestria' ||
                this.widget.user.degree_levels == 'Doctorado' ||
                this.widget.user.degree_levels == 'School' ||
                this.widget.user.degree_levels == 'College' ||
                this.widget.user.degree_levels == 'University' ||
                this.widget.user.degree_levels == 'Masters' ||
                this.widget.user.degree_levels == 'Doctorate') ...[
              Container(
                  margin: EdgeInsets.only(left: 30, right: 30),
                  child: TextFormField(
                    /*  initialValue: this.widget.user.speciality_or_degree != null
                        ? this.widget.user.speciality_or_degree
                        : '',*/
                    initialValue: this.widget.user.speciality_or_degree == '0'
                        ? ''
                        : _valSp,
                    decoration: InputDecoration(labelText: l10n.speciality),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_priceFocusNode);
                    },
                    validator: (value) {
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _valSp =
                            value; //Untuk memberitahu _valFriends bahwa isi nya akan diubah sesuai dengan value yang kita pilih
                      });
                    },
                    onSaved: (value) {},
                  ))
            ],
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Row(
              children: <Widget>[
                Expanded(
                    flex: 2,
                    child: Container(
                      margin: EdgeInsets.only(left: 30),
                      width: MediaQuery.of(context).size.width * 0.90,
                      alignment: Alignment.topLeft,
                      child: Text(l10n.languages,
                          style: TextStyle(
                              fontSize: 25,
                              color: HexColor('EA6012'),
                              fontWeight: FontWeight.bold)),
                    )),
                Expanded(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.only(right: 30),
                      width: MediaQuery.of(context).size.width * 0.10,
                      alignment: Alignment.topRight,
                      child: FloatingActionButton(
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 40,
                        ),
                        backgroundColor: HexColor('EA6012'),
                        onPressed: () {
                          _navigateAndDisplaySelection(context);
                          /* Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddLanguage(
                                      user: this.widget.user,
                                    )),
                          );*/
                        },
                      ),
                    ))
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            if (isData == true) ...[
              Container(
                  margin: EdgeInsets.only(left: 15, right: 15),
                  height: 200,
                  child: MediaQuery.removePadding(
                      removeTop: true,
                      context: context,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: myLannguages.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 2,
                                  child: Container(
                                    alignment: Alignment.topLeft,
                                    width: MediaQuery.of(context).size.width *
                                        0.80,
                                    margin: EdgeInsets.only(left: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          myLannguages[index]
                                                      ['other_language_text'] !=
                                                  null
                                              ? '${myLannguages[index]['other_language_text']}'
                                              : '${myLannguages[index]['language']}',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text('${myLannguages[index]['level']}',
                                            style: TextStyle(fontSize: 14))
                                      ],
                                    ),
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    margin: EdgeInsets.only(right: 10),
                                    alignment: Alignment.topRight,
                                    width: MediaQuery.of(context).size.width *
                                        0.20,
                                    child: IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: HexColor('EA6012'),
                                        ),
                                        onPressed: () {
                                          _navigateAndDisplaySelection1(
                                              context, myLannguages[index]);
                                        }),
                                  ))
                            ],
                          );
                        },
                      )))
            ],
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
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
                      onPressed: () {
                        if (_valNivel == null) {
                          _showErrorInput(
                              'Debe seleccionar el Nivel de Estudio');
                        } else {
                          //_saveForm();
                        }
                      },
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
