import 'key_finder_stub.dart'
    if (dart.library.io) 'package:clup_application/conditional_deps/mobile_keyfinder.dart'
    if (dart.library.html) 'package:clup_application/conditional_deps/web_keyfinder.dart';

abstract class KeyFinder {
  Future<String> getKeyValue(String key) {
    return Future.error('Calling from interface');
  }

  Future<void> setKeyValue(String key, String value);

  Future<void> deleteKey(String key);

  Future<bool> containsKey(String key);

  factory KeyFinder() => getKeyFinder();
}
