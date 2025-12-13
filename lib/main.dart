import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_proj/mobile/UI/auth/Registration.dart';
import 'package:hackathon_proj/mobile/bg_engine/bg.dart';
import 'mobile/UI/auth/Login.dart';
import 'mobile/UI/splash/ui.dart';
import 'mobile/UI/dashbord/ui.dart';
import 'Web/web dashboard.dart';

void main() {
  runApp(const FirstResponderApp());
}

class FirstResponderApp extends StatelessWidget {
  const FirstResponderApp({super.key});

  @override
  Widget build(BuildContext context) {
    BG_sync();
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
        '/web-dashboard': (context) => const WebDashboardPage(),
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

void BG_sync() {
  // timer forrun  every 5 seconds

  Timer.periodic(Duration(seconds: 10), (timer) async {
    bool is_connnected = _toOnline(await Connectivity().checkConnectivity());
    if (is_connnected) {
      Bg_engine.run_queue();
    }
  });

  // Connectivity().onConnectivityChanged.listen((result) {
  //   bool is_connnected = _toOnline(result);
  //   if (is_connnected) {
  //     Bg_engine.run_queue();
  //   }
  // });
}

bool _toOnline(dynamic result) {
  if (result is ConnectivityResult) {
    return result != ConnectivityResult.none;
  }
  if (result is List<ConnectivityResult>) {
    return result.any((r) => r != ConnectivityResult.none);
  }
  return false;
}
