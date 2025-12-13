import 'package:flutter/material.dart';
import 'package:hackathon_proj/mobile/UI/auth/Registration.dart';
import 'mobile/UI/auth/Login.dart';
import 'mobile/UI/splash/ui.dart';
import 'mobile/UI/dashbord/ui.dart';

void main() {
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
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegistrationPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
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
