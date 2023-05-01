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

  // off, auto, 1단, 2단
  final List<bool> _modeSelected = <bool>[false, false, false, false];
  // off, 제습, 가습
  final List<bool> _humiditySelected = <bool>[false, false, false];

  Future getData() async {
    try {
      // 서버에서 기기의 최신 데이터 정보를 계속 받아오기
      deviceState = await IoTApiService.getDeviceState(
          Provider.of<ServerInfo>(context, listen: false).pw.toString());

      if (firstLoding) {
        // 첫 로딩일 경우 현재 디바이스 설정 불러오기
        try {
          int mode = int.parse(deviceState['mode']);
          _modeSelected[mode] = true;
          if (mode == 2 || mode == 3) {
            if (deviceState['humidifier'] == true) {
              _humiditySelected[2] = true;
            } else if (deviceState['petier'] == true) {
              _humiditySelected[1] = true;
            }
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      }

      firstLoding = false;
      setState(() {});

      // debugPrint(deviceState.toString());
    } catch (e) {
      // 문제 발생시 상태를 false로 변경
      if (mounted) {
        Provider.of<ServerInfo>(context, listen: false).setState = false;
      }
      debugPrint(e.toString());
    }
  }

  // 위치 정보 불러오기
  void getLocationAndSurveyInfoData() async {
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
        address = '';
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
    getLocationAndSurveyInfoData();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void modeChange(String pw) async {
    int mode = 0;
    int humidityMode = 0;

    for (int i = 0; i < _modeSelected.length; i++) {
      if (_modeSelected[i]) {
        mode = i;

        break;
      }
    }

    for (int i = 0; i < _humiditySelected.length; i++) {
      if (_humiditySelected[i]) {
        humidityMode = i;

        break;
      }
    }

    debugPrint('mode: $mode, humidityMode: $humidityMode');

    try {
      await IoTApiService.setModeChange(pw, mode, humidityMode);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SummaryWidget(deviceState: deviceState, firstLoding: firstLoding),
          RealtimeInfoWidget(
              address: address,
              realtimeSurveyInformation: realtimeSurveyInformation),
          modeController(context)
        ],
      ),
    );
  }

  Container modeController(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Column(
        children: [
          const Text(
            '모드',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(
            height: 10,
          ),
          // 모드
          ToggleButtons(
            onPressed: !deviceState['state']
                ? null
                : (int index) {
                    setState(() {
                      for (int i = 0; i < _modeSelected.length; i++) {
                        // 누른 항목만 true로 변경
                        _modeSelected[i] = i == index;
                      }
                    });

                    if (index == 0 || index == 1) {
                      for (int i = 0; i < _humiditySelected.length; i++) {
                        _humiditySelected[i] = false;
                      }
                      _humiditySelected[0] = true;
                    }

                    // api 요청
                    modeChange(context.read<ServerInfo>().pw);
                  },
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            constraints: const BoxConstraints(
              minHeight: 40.0,
              minWidth: 80.0,
            ),
            isSelected: _modeSelected,
            children: const [Text('끄기'), Text('자동'), Text('미풍'), Text('강풍')],
          ),
          const SizedBox(
            height: 30,
          ),

          // 습도 조절
          const Text(
            '습도',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(
            height: 10,
          ),
          ToggleButtons(
            onPressed:
                _modeSelected[0] || _modeSelected[1] || !deviceState['state']
                    ? null
                    : (int index) {
                        setState(() {
                          for (int i = 0; i < _humiditySelected.length; i++) {
                            // 누른 항목만 true로 변경
                            _humiditySelected[i] = i == index;
                          }
                        });

                        // api 요청
                        modeChange(context.read<ServerInfo>().pw);
                      },
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            constraints: const BoxConstraints(
              minHeight: 40.0,
              minWidth: 80.0,
            ),
            isSelected: _humiditySelected,
            children: const [
              Text('끄기'),
              Text('제습'),
              Text('가습'),
            ],
          ),
        ],
      ),
    );
  }
}

class RealtimeInfoWidget extends StatelessWidget {
  const RealtimeInfoWidget({
    super.key,
    required this.address,
    required this.realtimeSurveyInformation,
  });

  final String address;
  final Map<String, dynamic> realtimeSurveyInformation;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$address 지역의 대기 상태',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
                    Row(children: [
                      const Text('PM 2.5 '),
                      Text('${realtimeSurveyInformation['pm25Value']}μg/m³')
                    ]),
                    Row(children: [
                      const Text('PM 10.0 '),
                      Text('${realtimeSurveyInformation['pm10Value']}μg/m³')
                    ]),
                    Row(children: [
                      const Text('O₃ '),
                      Text('${realtimeSurveyInformation['o3Value']}ppm')
                    ]),
                    Row(children: [
                      const Text('NO₂ '),
                      Text('${realtimeSurveyInformation['o3Value']}ppm')
                    ]),
                    Row(children: [
                      const Text('CO '),
                      Text('${realtimeSurveyInformation['coValue']}ppm')
                    ]),
                    Row(children: [
                      const Text('SO₂ '),
                      Text('${realtimeSurveyInformation['o3Value']}ppm')
                    ]),
                  ],
                )
              ],
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
