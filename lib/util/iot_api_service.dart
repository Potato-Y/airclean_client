import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class IoTApiService {
  static const String baseUrl = 'http://ariclean.duckdns.org:3000';

  static Future<String> getServerState() async {
    final url = Uri.parse('$baseUrl/ping');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      debugPrint(response.body);
      return response.body;
    }

    throw Error();
  }

  static Future<Map<String, dynamic>> getAuthCheck(String pw) async {
    final url = Uri.parse('$baseUrl/auth_check');
    final response = await http.post(url,
        body: json.encode({'pw': pw}),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Error();
  }

  static Future<Map<String, dynamic>> getDeviceState(String pw) async {
    final url = Uri.parse('$baseUrl/now_device_state');
    final response = await http.post(url,
        body: json.encode({'pw': pw}),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Error();
  }

  static Future<Map<String, dynamic>> setModeChange(
      String pw, int mode, int humidityMode) async {
    final url = Uri.parse('$baseUrl/mode_change');
    final response = await http.post(url,
        body: json.encode({
          'pw': pw,
          'mode': mode,
          'humidityMode': humidityMode,
        }),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Error();
  }
}
