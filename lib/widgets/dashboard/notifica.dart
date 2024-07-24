import 'package:flutter/material.dart';

class NotiTest extends StatefulWidget {
  static const routeName = '/notifi';

  @override
  _NotiTestState createState() => _NotiTestState();
}

class _NotiTestState extends State<NotiTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Icon(Icons.notification_important),
      ),
    );
  }
}
