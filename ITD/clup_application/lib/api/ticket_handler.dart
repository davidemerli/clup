import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../main.dart';

createTicket(storeID) async {
  var body = {'store_id': storeID};

  try {
    var response = await connectToClup(route: "/create_ticket", data: body);

    if (kDebugMode) print(response);

    if (response.statusCode == 200) {
      if (response.data['success']) {
        Map ticket = response.data['ticket'];
        write(key: 'ticket', value: json.encode(ticket));

        return [true, ticket];
      } else {
        await updateTicketInfo();

        return [false, response['errors']];
      }
    }
  } catch (e) {}

  return [false, 'Could not connect to server'];
}

getTicket() async {
  if (await containsKey(key: 'ticket')) {
    return json.decode(await read(key: 'ticket'));
  } else {
    return Map();
  }
}

updateTicketInfo() async {
  try {
    var response = await connectToClup(route: "/active_ticket");

    if (kDebugMode) print(response);

    if (response.statusCode == 200 && response.data['success']) {
      write(key: 'ticket', value: json.encode(response.data['ticket']));

      return [true, response.data['ticket']];
    }
  } catch (e) {
    if (kDebugMode) print(e);
  }

  return [false, null];
}

cancelTicket() async {
  try {
    var response = await connectToClup(route: "/cancel_ticket");

    if (kDebugMode) print(response);

    if (response.statusCode == 200 && response.data['success']) {
      await delete(key: 'ticket');

      return true;
    }
  } catch (e) {
    return false;
  }

  return false;
}
