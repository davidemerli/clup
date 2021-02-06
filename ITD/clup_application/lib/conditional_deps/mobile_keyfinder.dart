import 'package:clup_application/conditional_deps/keyfinder_interface.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SharedPrefKeyFinder implements KeyFinder {
  FlutterSecureStorage storage = FlutterSecureStorage();

  Future<String> getKeyValue(String key) async {
    return await storage.read(key: key);
  }

  Future<void> setKeyValue(String key, String value) async {
    return storage.write(key: key, value: value);
  }

  @override
  Future<bool> containsKey(String key) async {
    return await storage.containsKey(key: key);
  }

  @override
  Future<void> deleteKey(String key) async {
    return await storage.delete(key: key);
  }
}

KeyFinder getKeyFinder() => SharedPrefKeyFinder();
