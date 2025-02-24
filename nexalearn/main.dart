import 'package:flutter/material.dart';

import 'package:nexalearn/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NexaLearnApp());
}

class NexaLearnApp extends StatelessWidget {
  const NexaLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexaLearn',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const  HomeScreen(),
    );
  }
}
