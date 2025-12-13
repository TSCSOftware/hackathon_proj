import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hackathon_proj/main.dart';
import 'package:hackathon_proj/mobile/UI/auth/Login.dart';
import 'package:hackathon_proj/mobile/UI/dashbord/ui.dart';
import 'package:hackathon_proj/mobile/api/pb.dart';

Future init_Splash(BuildContext context) async {
  var userid = await storage.read(key: "vv_id");
  if (Platform.isAndroid) {
      await initializeService();
  startBackgroundService() ;
  }

  if (userid != null) {
    await ApiService.token_login();
    GotoPage(context, const DashboardPage(), isReplace: true);
  } else {
    GotoPage(context, const LoginPage(), isReplace: true);
  }
}
