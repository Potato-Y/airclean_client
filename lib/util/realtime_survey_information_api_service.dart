import 'dart:convert';

import 'package:http/http.dart' as http;

class RealtimeSurveyInformationApiService {
  static const String baseUrl =
      'http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getCtprvnRltmMesureDnsty';
  static const String key =
      'NjwYIrULMB18nw6OChgPbwH39j6A%2BfQUP4YNsWna8zPziLNj1plJp5rBD7hCvQLzjfpDGmXDXyUy%2FBBUpZgIfg%3D%3D';

  static Future<Map<String, dynamic>> getRegion1DepthName(
      String address) async {
    final url = Uri.parse(
        '$baseUrl?serviceKey=$key&returnType=json&numOfRows=1&sidoName=$address');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // debugPrint(response.body);
      return jsonDecode(response.body)['response']['body']['items'][0];
    }

    throw Error();
  }
}
