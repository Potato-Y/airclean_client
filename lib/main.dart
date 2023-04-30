import 'package:airclean_client/model/state/server_info.dart';
import 'package:airclean_client/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

void main(List<String> args) async {
  /// Android 플랫폼에서 상단 바를 투명하게 수정
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarBrightness: Brightness.light,
      statusBarColor: Colors.transparent,

      /// 안드로이드 플랫폼에서 네비게이션 바의 배경 색을 설정
      systemNavigationBarColor: Colors.white,
    ),
  );

  /// 앱 파일의 유요한 디렉터리로 Hive 초기화
  await Hive.initFlutter();

  await Hive.openBox('app');

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => ServerInfo(),
      )
    ],
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // 기본 기능 불러오기
    final box = Hive.box('app');
    String? pwd = box.get('pwd');
    debugPrint(pwd);
    if (pwd != null) {
      context.read<ServerInfo>().setPwd = pwd;
    }

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
