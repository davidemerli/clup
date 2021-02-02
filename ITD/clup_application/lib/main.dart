import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'pages/map_page.dart';
import 'pages/signup_confirm_page.dart';
import 'pages/ticket_page.dart';
import 'pages/signup_page.dart';
import 'pages/login_page.dart';
import 'pages/store_view_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _lockRotation();

    return MaterialApp(
      title: 'CLup Application',
      theme: _appTheme(),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        "/": (BuildContext context) => LoginPage(),
        "/signup": (BuildContext context) => SignupPage(),
        "/signup/confirm": (BuildContext context) => SignupConfirmPage(),
        "/store/ticket": (BuildContext context) => TicketPage(),
        "/map": (BuildContext context) => MapPage(),
        "/store": (BuildContext context) => StoreViewPage(),
      },
    );
  }

  ThemeData _appTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.lightBlue,
      accentColor: Colors.cyan,
      fontFamily: 'Nunito',
      textTheme: TextTheme(
        headline4: TextStyle(
          fontSize: 40.0,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
        headline5: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w500),
        headline6: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
        bodyText1: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),
        button: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w300),
      ),
    );
  }

  void _lockRotation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
