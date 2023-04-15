import 'package:airclean_client/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';

void main(List<String> args) async {
  /// Android 플랫폼에서 상단 바를 투명하게 수정
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarBrightness: Brightness.light,
      statusBarColor: Colors.transparent,

      /// 안드로이드 플랫폼에서 네비게이션 바의 배경 색을 설정
      systemNavigationBarColor: Colors.indigo[300],
    ),
  );

  /// 앱 파일의 유요한 디렉터리로 Hive 초기화
  await Hive.initFlutter();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 87, 145, 207),
          // brightness: Brightness.dark,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}
