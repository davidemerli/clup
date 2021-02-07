import 'key_finder_stub.dart' // Custom imports to avoid conflicting dependencies
    if (dart.library.io) 'package:clup_application/conditional_deps/mobile_keyfinder.dart'
    if (dart.library.html) 'package:clup_application/conditional_deps/web_keyfinder.dart';

abstract class KeyFinder {
  /// Returns a value given a key
  Future<String> getKeyValue(String key) {
    return Future.error('Calling from interface');
  }

  /// Sets <key,value> pair
  Future<void> setKeyValue(String key, String value);

  /// Deletes a key
  Future<void> deleteKey(String key);

  /// Returns true if given key is present
  Future<bool> containsKey(String key);

  /// Creates KeyFinder instance
  factory KeyFinder() => getKeyFinder();
}
