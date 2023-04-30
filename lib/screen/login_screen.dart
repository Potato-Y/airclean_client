import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../model/state/server_info.dart';
import '../util/api_service.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final idController = TextEditingController();
  final pwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '공기 청정기에 연결하기',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              // SizedBox(
              //   width: MediaQuery.of(context).size.width * 0.8,
              //   height: 50,
              //   child: TextField(
              //     controller: idController,
              //     decoration: InputDecoration(
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(25),
              //       ),
              //       labelText: 'Server IP',
              //     ),
              //     textInputAction: TextInputAction.next,
              //     onSubmitted: (_) => FocusScope.of(context).nextFocus(),
              //   ),
              // ),
              // const SizedBox(
              //   height: 8,
              // ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 50,
                child: TextField(
                  controller: pwController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    labelText: 'Password',
                  ),
                  textInputAction: TextInputAction.done,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      Map<String, dynamic> response =
                          await ApiService.getAuthCheck(pwController.text);
                      if (response['result'] == true && context.mounted) {
                        // 로그인 성공 시 pw 저장
                        context.read<ServerInfo>().setPwd = pwController.text;
                        context.read<ServerInfo>().setState = true;
                      }
                    } catch (e) {
                      Fluttertoast.showToast(msg: '서버에 접속할 수 없습니다.');
                    }
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.login),
                  label: const Text('접속하기'),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
