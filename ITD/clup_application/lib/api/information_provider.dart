import 'dart:convert';

import '../main.dart';

loadNearbyStores(latitude, longitude) async {
  var body = {'latitude': latitude, 'longitude': longitude, 'radius_km': 100};

  try {
    var response = await connectToClup(route: "/nearby_stores", data: body);

    if (response.statusCode == 200) {
      return response.data['stores'];
    }
  } catch (e) {
    return [];
  }
}

selectStore(Map store) async {
  await write(key: 'selected_store', value: json.encode(store));
}

getSelectedStore() async {
  if (await containsKey(key: "selected_store")) {
    return json.decode(await read(key: 'selected_store'));
  } else {
    if (await containsKey(key: 'ticket')) {
      var ticket = json.decode(await read(key: 'ticket'));

      if (await containsKey(key: 'ticket') && ticket != null) {
        return await getStoreInfo(ticket['ticket_id']);
      }
    }
  }
  return Map();
}

getStoreInfo(storeID) async {
  try {
    var data = {'store_id': storeID};
    var response = await connectToClup(route: '/store_info', data: data);

    if (response.statusCode == 200) {
      return response.data['store'];
    } else {
      return Map();
    }
  } catch (e) {
    return Map();
  }
}
