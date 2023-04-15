import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Air Clean'),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 253, 230),
    );
  }
}
