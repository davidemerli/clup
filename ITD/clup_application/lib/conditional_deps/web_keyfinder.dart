// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:clup_application/conditional_deps/keyfinder_interface.dart';

class WebKeyFinder implements KeyFinder {
  Window windowLoc = window;

  Future<String> getKeyValue(String key) async {
    return Future.value(windowLoc.localStorage[key]);
  }

  Future<void> setKeyValue(String key, String value) async {
    windowLoc.localStorage[key] = value;
  }

  @override
  Future<bool> containsKey(String key) async {
    return Future.value(windowLoc.localStorage.containsKey(key));
  }

  @override
  Future<void> deleteKey(String key) async {
    windowLoc.localStorage.remove(key);
  }
}

KeyFinder getKeyFinder() => WebKeyFinder();
