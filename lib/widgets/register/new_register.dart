import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/users.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../register/confirmed.dart';
import 'package:worker/providers/url_constants.dart';
import '../../local/database_creator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:worker/model/config.dart';
import 'package:url_launcher/url_launcher.dart';
import '../global.dart';

class RegisterUserNew extends StatefulWidget {
  const RegisterUserNew({Key? key}) : super(key: key);

  @override
  _RegisterUserNewState createState() => _RegisterUserNewState();
}

class _RegisterUserNewState extends State<RegisterUserNew> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _isLoading = false;
  late String name = '';
  late String lastname;
  late String email;
  late String password;
  late String password1;
  late Config config;
  late String phone;
  late String l;
  final _passwordController = TextEditingController();
  var maskTextInputFormatter =
      MaskTextInputFormatter(filter: {"": RegExp(r'[a-z, @]')});

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        titleTextStyle: TextStyle(
            color: HexColor('373737'),
            fontFamily: 'OpenSansRegular',
            fontWeight: FontWeight.bold,
            fontSize: 20),
        actions: <Widget>[
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> getTodo() async {
    final sql =
        '''SELECT * FROM ${DatabaseCreator.todoTable} WHERE ${DatabaseCreator.id} = ?''';
    List<dynamic> params = [1];
    final data = await db.rawQuery(sql, params);
    final todo = Config.fromJson(data.first);
    setState(() {
      config = todo;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<Users>(context, listen: false)
          .addUser(name, lastname, email, password, config.language)
          .then((response) {
        setState(() {
          _isLoading = false;
        });
        if (response['status'] == '201') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ConfirmedRegister(email, response['data']['id'], 0)),
          );
        } else {
          switch (response['data'].toString()) {
            case "{email: [A user with that email address already exists.]}":
              _showErrorDialog('El email ya se encuentra registrado');
              break;
            default:
          }
        }
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('An error occurred');
    }
  }

  Future<void> getLang() async {
    SharedPreferences lang = await SharedPreferences.getInstance();
    String? stringValue = lang.getString('stringValue');
    l = stringValue!;
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    getTodo();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.23,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomRight,
                          end: Alignment.topLeft,
                          colors: [
                            HexColor('FBB03B'),
                            HexColor('EF6826'),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.06),
                          Container(
                            margin: const EdgeInsets.only(left: 5.0),
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.03),
                          Container(
                            margin: const EdgeInsets.only(left: 20.0),
                            alignment: Alignment.topLeft,
                            child: Text(
                              l10n.register_user,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 35,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(top: 130.0),
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.06),
                                Text(
                                  l10n.register_user1,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.04),
                                _buildTextFormField(
                                  hintText: l10n.key_first_name,
                                  icon: Icons.note,
                                  onChanged: (value) => name = value,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                _buildTextFormField(
                                  hintText: l10n.key_last_name,
                                  icon: Icons.note,
                                  onChanged: (value) => lastname = value,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                _buildTextFormField(
                                  hintText: l10n.key_email,
                                  icon: Icons.email,
                                  onChanged: (value) => email = value,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                _buildTextFormField(
                                  hintText: l10n.phone_number,
                                  icon: Icons.phone,
                                  onChanged: (value) => phone = value,
                                  keyboardType: TextInputType.phone,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                _buildTextFormField(
                                  hintText: l10n.key_password,
                                  icon: Icons.lock,
                                  onChanged: (value) => password = value,
                                  obscureText: true,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02),
                                _buildTextFormField(
                                  hintText: l10n.confirm_password,
                                  icon: Icons.lock,
                                  onChanged: (value) => password1 = value,
                                  obscureText: true,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.03),
                                Row(
                                  children: [
                                    Text(
                                      l10n.create,
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () => _launchURL(
                                          "${ApiWebServer.server_name}/terms-and-conditions"),
                                      child: Text(
                                        l10n.term_cond,
                                        style: const TextStyle(
                                            fontSize: 13, color: Colors.grey),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      l10n.and,
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.grey),
                                    ),
                                    const SizedBox(width: 2),
                                    InkWell(
                                      onTap: () => _launchURL(
                                          "${ApiWebServer.server_name}/privacy-policy"),
                                      child: Text(
                                        l10n.privacy,
                                        style: const TextStyle(
                                            fontSize: 13, color: Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.03),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 1.0),
                                  width: double.infinity,
                                  child: _isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    HexColor('EA6012')),
                                          ),
                                          onPressed: _submit,
                                          child: Text(
                                            l10n.button_register,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String hintText,
    required IconData icon,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        prefixIcon: Icon(icon, color: HexColor('EA6012'), size: 20.0),
        contentPadding: const EdgeInsets.only(left: 15.0, top: 15.0),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'Quicksand'),
      ),
      onChanged: onChanged,
    );
  }
}
