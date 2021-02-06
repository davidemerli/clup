import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../main.dart';

getQueueStatus() async {
  try {
    var response = await connectToClup(route: '/queue_status');

    if (kDebugMode) print(response);

    if (response.statusCode == 200) {
      var data = json.decode(response.toString());

      if (data['success']) {
        return [true, data];
      } else {
        return [false, data['errors']];
      }
    }
  } catch (e) {
    return [false, 'Connection failed.'];
  }
}

callFirstInQueue() async {
  try {
    var response = await connectToClup(route: "/call_first");

    if (kDebugMode) print(response);

    if (response.statusCode == 200) {
      var data = json.decode(response.toString());

      if (data['success']) {
        return [true, data['empty_list']];
      } else {
        return [false, data['errors']];
      }
    }
  } catch (e) {
    return [false, 'Connection failed.'];
  }
}

acceptTicket(ticketID) async {
  try {
    var body = {'ticket_id': ticketID};

    var response = await connectToClup(route: "/accept_ticket", data: body);

    if (kDebugMode) print(response);

    if (response.statusCode == 200) {
      var data = json.decode(response.toString());

      if (data['success']) {
        return [true];
      } else {
        return [false, data['errors']];
      }
    }
  } catch (e) {
    return [false, 'Connection failed.'];
  }
}
