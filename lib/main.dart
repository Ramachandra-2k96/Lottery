import 'package:flutter/material.dart';
import 'lottery_wheel.dart'; // Make sure to create this file with the LotteryWheel widget

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: LotteryWheel(),
      ),
    );
  }
}