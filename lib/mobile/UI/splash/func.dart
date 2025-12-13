import 'package:flutter/material.dart';
import 'package:hackathon_proj/main.dart';
import 'package:hackathon_proj/mobile/UI/auth/Login.dart';
import 'package:hackathon_proj/mobile/UI/dashbord/ui.dart';
import 'package:hackathon_proj/mobile/api/pb.dart';

Future init_Splash(BuildContext context) async {
  var userid = await storage.read(key: "vv_id");
  if (userid != null) {
    GotoPage(context, const DashboardPage(), isReplace: true);
  } else {
    GotoPage(context, const LoginPage(), isReplace: true);
  }
}
