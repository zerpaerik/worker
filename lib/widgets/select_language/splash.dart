import 'package:flutter/material.dart';
import 'select.dart';

class SplashPage extends StatefulWidget {
  static const routeName = '/splash-screen';
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SelectLang()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Stack(children: <Widget>[
      Positioned.fill(
        child: Image(
          image: AssetImage('assets/splash.png'),
          fit: BoxFit.fill,
        ),
      ),
    ]);
  }
}
