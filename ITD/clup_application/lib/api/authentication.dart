import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const CLUP_URL = "http://192.168.1.66:5000";

final Dio dio = Dio();
final FlutterSecureStorage storage = FlutterSecureStorage();

getAccessToken() async {
  String accessToken = await storage.read(key: 'access_token');

  return accessToken;
}

getRefreshToken() async {
  String refreshToken = await storage.read(key: 'refresh_token');

  return refreshToken;
}

attemptLogin(email, password) async {
  var body = {'email': email, 'password': password};

  try {
    var response = await dio.post(CLUP_URL + "/login", data: body);

    if (response.statusCode == 200) {
      var data = json.decode(response.toString());

      if (data['success']) {
        String accessToken = data['access_token'];
        String refreshToken = data['refresh_token'];

        storage.write(key: 'access_token', value: accessToken);
        storage.write(key: 'refresh_token', value: refreshToken);

        return [true];
      }
    }
  } catch (e) {
    return [false, 'Connection failed.'];
  }

  return [false, 'Incorrect username or password'];
}

logout() {
  storage.delete(key: 'access_token');
  storage.delete(key: 'refresh_token');
}

registerAccount() {}
