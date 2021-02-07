import 'package:flutter/foundation.dart';

import '../configs.dart';
import '../main.dart';

Future<String> getAccessToken() async {
  String accessToken = await read(key: 'access_token');

  return accessToken;
}

Future<String> getRefreshToken() async {
  String refreshToken = await read(key: 'refresh_token');

  return refreshToken;
}

Future<List> attemptLogin(email, password) async {
  var body = {'email': email, 'password': password};

  try {
    var response = await dio.post(CLUP_URL + "/login", data: body);

    if (kDebugMode) print(response);

    if (response.statusCode == 200) {
      if (response.data['success']) {
        String accessToken = response.data['access_token'];
        String refreshToken = response.data['refresh_token'];
        String clupRole = response.data['clup_role'];

        await write(key: 'access_token', value: accessToken);
        await write(key: 'refresh_token', value: refreshToken);
        await write(key: 'clup_role', value: clupRole);

        dio.options.headers['content-type'] = 'application/json';
        dio.options.headers["Authorization"] = "Bearer $accessToken";

        return [true];
      }
    }
  } catch (e) {
    if (kDebugMode) print(e);

    return [false, e.toString()];
  }

  return [false, 'Incorrect username or password'];
}

Future<void> logout() async {
  await delete(key: 'access_token');
  await delete(key: 'refresh_token');
}

Future<List> registerAccount(name, email, password) async {
  var body = {'name': name, 'email': email, 'password': password};

  try {
    var response = await dio.post(CLUP_URL + "/register", data: body);

    if (kDebugMode) print(response);

    if (response.statusCode == 200) {
      if (response.data['success']) {
        return [true];
      } else {
        return [false, response.data['errors']];
      }
    }
  } catch (e) {}

  return [false, 'Connection failed.'];
}

Future<bool> isUser() async {
  return await read(key: 'clup_role') == 'USER';
}

Future<bool> isOperator() async {
  return await read(key: 'clup_role') == 'OPERATOR';
}

Future<List> refreshAuth() async {
  try {
    dio.options.headers['content-type'] = 'application/json';
    dio.options.headers['Authorization'] = "Bearer ${await getRefreshToken()}";

    if (kDebugMode) print('API REQUEST - route:/refresh, data:{}');

    var response = await dio.post(CLUP_URL + "/refresh", data: {});

    if (kDebugMode) print(response);

    if (response.statusCode == 200) {
      if (response.data['success']) {
        String accessToken = response.data['access_token'];

        write(key: 'access_token', value: accessToken);

        dio.options.headers['content-type'] = 'application/json';
        dio.options.headers['Authorization'] = "Bearer $accessToken";

        return [true];
      } else {
        return [false, response.data['errors']];
      }
    } else {
      return [false, response.statusMessage];
    }
  } catch (e) {
    if (kDebugMode) print(e);

    return [false, e.toString()];
  }
}
