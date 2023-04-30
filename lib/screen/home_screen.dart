import 'package:airclean_client/model/state/server_info.dart';
import 'package:airclean_client/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Scaffold build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Air Clean'),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 253, 230),
      body: AnimatedSwitcher(
        duration: const Duration(microseconds: 500),
        child: context.watch<ServerInfo>().state == false
            ? LoginScreen()
            : const Text('hi2'),
      ),
    );
  }
}
