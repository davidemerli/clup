import 'package:clup_application/api/authentication.dart';
import 'package:clup_application/conditional_deps/keyfinder_interface.dart';
import 'package:clup_application/pages/operator_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'pages/map_page.dart';
import 'pages/signup_confirm_page.dart';
import 'pages/ticket_page.dart';
import 'pages/signup_page.dart';
import 'pages/login_page.dart';
import 'pages/store_view_page.dart';

import 'configs.dart';

final Dio dio = Dio();
final KeyFinder keyFinder = KeyFinder();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _lockRotation();
    _setupAccessControlHeaders();

    return MaterialApp(
      title: 'CLup Application',
      theme: _appTheme(),
      initialRoute: '/login',
      routes: {
        "/login": (context) => LoginPage(),
        "/signup": (context) => SignupPage(),
        "/signup/confirm": (context) => SignupConfirmPage(),
        "/store/ticket": (context) => TicketPage(),
        "/map": (context) => MapPage(),
        "/map/store": (context) => StoreViewPage(),
        "/operator_page": (context) => OperatorPage(),
      },
    );
  }

  /// Setups headers for the webapp to be able to be accessed freely from other ips
  void _setupAccessControlHeaders() {
    dio.options.headers['Access-Control-Allow-Headers'] = '*';
    dio.options.headers['Access-Control-Allow-Origin'] = '*';
    dio.options.headers['Access-Control-Allow-Methods'] =
        'POST,GET,DELETE,PUT,OPTIONS';
  }

  /// Defines the theme of the application
  ThemeData _appTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: clupBlue1,
      accentColor: clupBlue2,
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

  /// Locks rotation on mobile
  void _lockRotation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}

/// Deletes a key, value pair from local storage
Future<void> delete({String key}) async {
  await keyFinder.deleteKey(key);
}

/// Writes a key, value pair from local storage
Future<void> write({String key, String value}) async {
  return await keyFinder.setKeyValue(key, value);
}

/// Retrieves a value given a key from local storage
Future<String> read({String key}) async {
  return await keyFinder.getKeyValue(key);
}

/// Returns true if given key is present in local storage
Future<bool> containsKey({String key}) async {
  return await keyFinder.containsKey(key);
}

/// Connects to api given API route and a Map containing data
Future connectToClup({String route, Map data}) async {
  try {
    /// All API requests are POST requests
    var response = await dio.post(CLUP_URL + route, data: data ?? {});

    if (kDebugMode) print(response);

    return response;
  } catch (e) {
    if (kDebugMode) print(e.toString());

    // If the requests fails and it may be a auth token expiration, tries to recieve
    // a new auth token sending the refresh token
    if (e is DioError &&
        (e.response.statusCode == 500 || e.response.statusCode == 401)) {
      List refreshResult = await refreshAuth();

      if (kDebugMode) print(refreshResult);

      // If refresh token request had a positive response, retry to send the original request
      if (refreshResult[0]) {
        return connectToClup(route: route, data: data);
      } else {
        //Otherwise, logout the application
        await logout();

        return Future.error('Authentication expired');
      }
    }

    return Future.error('Could not connect to server');
  }
}
