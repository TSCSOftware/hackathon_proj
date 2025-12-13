import 'package:flutter/material.dart';
import 'package:hackathon_proj/Web/dash.dart';
import 'package:hackathon_proj/Web/web%20dashboard.dart';

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
 home: WebDashPage
 (),
    );
  }
}

void GotoPage(BuildContext context, Widget page, {bool isReplace = false}) {
  if (isReplace) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return page;
        },
      ),
    );
  } else {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return page;
        },
      ),
    );
  }
}