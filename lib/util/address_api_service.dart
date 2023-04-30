import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddressApiService {
  static const String baseUrl =
      'https://dapi.kakao.com/v2/local/geo/coord2address';

  static Future<String> getRegion1DepthName(
      double longitude, double latitude) async {
    final url = Uri.parse('$baseUrl?x=$longitude&y=$latitude');
    final response = await http.get(url,
        headers: {'Authorization': 'KakaoAK 7f58ce74a299a2fad6d87f0212d06535'});
    if (response.statusCode == 200) {
      debugPrint(response.body);
      return jsonDecode(response.body)['documents'][0]['road_address']
          ['region_1depth_name'];
    }

    throw Error();
  }
}
