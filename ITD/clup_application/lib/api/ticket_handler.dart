import 'dart:convert';

import 'package:clup_application/api/authentication.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final Dio dio = Dio();
final FlutterSecureStorage storage = FlutterSecureStorage();

const CLUP_URL = "http://192.168.1.66:5000";

createTicket(storeID) async {
  var body = {'store_id': storeID};

  try {
    dio.options.headers['content-type'] = 'application/json';
    dio.options.headers["Authorization"] = "Bearer ${await getAccessToken()}";

    var response = await dio.post(CLUP_URL + "/create_ticket", data: body);

    if (response.statusCode == 200) {
      Map ticket = response.data['ticket'];
      storage.write(key: 'ticket', value: json.encode(ticket));

      return ticket;
    }
  } catch (e) {
    return [];
  }
}

getTicket() async {
  if (await storage.containsKey(key: 'ticket')) {
    return json.decode(await storage.read(key: 'ticket'));
  } else {
    return Map();
  }
}
