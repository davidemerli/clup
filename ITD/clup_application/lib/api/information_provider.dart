import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:clup_application/api/authentication.dart';
import 'package:dio/dio.dart';

final Dio dio = Dio();
final FlutterSecureStorage storage = FlutterSecureStorage();

const CLUP_URL = "http://192.168.1.66:5000";

loadNearbyStores(latitude, longitude) async {
  var body = {'latitude': latitude, 'longitude': longitude, 'radius_km': 100};

  try {
    dio.options.headers['content-type'] = 'application/json';
    dio.options.headers["Authorization"] = "Bearer ${await getAccessToken()}";

    var response = await dio.post(CLUP_URL + "/nearby_stores", data: body);

    if (response.statusCode == 200) {
      return response.data['stores'];
    }
  } catch (e) {
    return [];
  }
}

selectStore(Map store) async {
  storage.write(key: 'selected_store', value: json.encode(store));
}

getSelectedStore() async {
  if (await storage.containsKey(key: "selected_store")) {
    return json.decode(await storage.read(key: 'selected_store'));
  } else {
    return Map();
  }
}
