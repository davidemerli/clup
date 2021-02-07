import 'package:clup_application/conditional_deps/keyfinder_interface.dart';

KeyFinder getKeyFinder() => throw UnsupportedError(
    'Cannot create a keyfinder without the packages dart:html or package:flutter_secure_storage');
