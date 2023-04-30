import 'dart:async';

import 'package:airclean_client/model/state/server_info.dart';
import 'package:airclean_client/util/address_api_service.dart';
import 'package:airclean_client/util/iot_api_service.dart';
import 'package:airclean_client/util/location.dart';
import 'package:airclean_client/util/realtime_survey_information_api_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class AircleanControllerScreen extends StatefulWidget {
  const AircleanControllerScreen({super.key});

  @override
  State<AircleanControllerScreen> createState() =>
      _AircleanControllerScreenState();
}

class _AircleanControllerScreenState extends State<AircleanControllerScreen> {
  Map<String, dynamic> deviceState = {'state': false};
  Map<String, dynamic> realtimeSurveyInformation = {};
  bool firstLoding = true;
  late Timer timer;
  String address = '';

  Future getData() async {
    try {
      // 서버에서 기기의 최신 데이터 정보를 계속 받아오기
      deviceState = await IoTApiService.getDeviceState(
          Provider.of<ServerInfo>(context, listen: false).pw.toString());
      firstLoding = false;
      setState(() {});

      debugPrint(deviceState.toString());
    } catch (e) {
      // 문제 발생시 상태를 false로 변경
      if (mounted) {
        Provider.of<ServerInfo>(context, listen: false).setState = false;
      }
      debugPrint(e.toString());
    }
  }

  // 위치 정보 불러오기
  void getLocationData() async {
    Location location = Location();

    // gps로부터 좌표 받기
    await location.getCurrentLocation();

    // 받은 좌표로 지역 정보 불러오기
    try {
      address = await AddressApiService.getRegion1DepthName(
          location.longitude, location.latitude);

      // 받은 주소를 통해 대기 상태 받아오기
      try {
        realtimeSurveyInformation =
            await RealtimeSurveyInformationApiService.getRegion1DepthName(
                address);
        debugPrint(realtimeSurveyInformation.toString());
      } catch (e) {
        debugPrint('정보 불러오기 오류');
        Fluttertoast.showToast(msg: '실시간 정보를 불러오지 못했습니다.');
      }
    } catch (e) {
      debugPrint(e.toString());
      Fluttertoast.showToast(msg: '위치 정보를 가져올 수 없습니다.');
    }
  }

  // initState() 함수에서 Timer를 이용해 1초마다 getData() 함수 호출
  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 2), (timer) {
      getData();
    });
    getLocationData();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SummaryWidget(deviceState: deviceState, firstLoding: firstLoding),
          Container(
            width: MediaQuery.of(context).size.width - 40,
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: address != ''
                  ? const Color.fromARGB(255, 87, 145, 207)
                  : const Color.fromARGB(255, 140, 140, 140),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (address == '')
                  const Text(
                    '지역 정보를 불러오는 중',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                if (address != '')
                  Text(
                    '$address 지역의 대기 상태',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryWidget extends StatelessWidget {
  const SummaryWidget({
    super.key,
    required this.deviceState,
    required this.firstLoding,
  });

  final Map<String, dynamic> deviceState;
  final bool firstLoding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: deviceState['state']!
            ? const Color.fromARGB(255, 87, 145, 207)
            : const Color.fromARGB(255, 140, 140, 140),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '나의 공간',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          if (firstLoding) const Text('정보를 불러오는 중입니다.'),
          if (!deviceState['state'] && !firstLoding)
            Row(
              children: const [
                Icon(Icons.signal_wifi_connected_no_internet_4_rounded),
                SizedBox(
                  width: 10,
                ),
                Text('기기가 오프라인입니다.'),
              ],
            ),
          if (deviceState['state'])
            Column(
              children: [
                Row(children: [
                  const Text('온도 '),
                  Text('${deviceState['temperature']}℃')
                ]),
                Row(children: [
                  const Text('습도 '),
                  Text("${deviceState['humidity']}%")
                ]),
                Row(children: [
                  const Text('PM 1.0 '),
                  Text('${deviceState['dust']['1.0']}μg/m³')
                ]),
                Row(children: [
                  const Text('PM 2.5 '),
                  Text('${deviceState['dust']['2.5']}μg/m³')
                ]),
                Row(children: [
                  const Text('PM 10.0 '),
                  Text('${deviceState['dust']['10.0']}μg/m³')
                ]),
                Row(children: [
                  const Text('GAS '),
                  Text('Lv.${deviceState['gas']}')
                ]),
              ],
            )
        ],
      ),
    );
  }
}
