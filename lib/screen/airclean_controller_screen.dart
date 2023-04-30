import 'dart:async';

import 'package:airclean_client/model/state/server_info.dart';
import 'package:airclean_client/util/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AircleanControllerScreen extends StatefulWidget {
  const AircleanControllerScreen({super.key});

  @override
  State<AircleanControllerScreen> createState() =>
      _AircleanControllerScreenState();
}

class _AircleanControllerScreenState extends State<AircleanControllerScreen> {
  Map<String, dynamic> deviceState = {'state': false};
  bool firstLoding = true;
  late Timer timer;

  Future getData() async {
    try {
      // 서버에서 기기의 최신 데이터 정보를 계속 받아오기
      deviceState = await ApiService.getDeviceState(
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

  // initState() 함수에서 Timer를 이용해 1초마다 getData() 함수 호출
  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 2), (timer) {
      getData();
    });
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
      margin: const EdgeInsets.all(20),
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
