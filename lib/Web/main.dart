import 'package:flutter/material.dart';
import 'package:hackathon_proj/Web/dash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FirstResponderApp());
}

class FirstResponderApp extends StatelessWidget {
  const FirstResponderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FirstResponder',
      theme: ThemeData(primarySwatch: Colors.red),
      home: WebDashPage(),
    );
  }
}
