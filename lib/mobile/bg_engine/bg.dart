import 'dart:isolate';

import 'package:hackathon_proj/mobile/bg_engine/bgtask.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

class Bg_engine {
  static void initialize() {
    print("Background engine initialized");
    // Add background tasks or services initialization here
  }

  static void send_request(var msg) {}

  static Future<void> add_to_queue(Bgtask task) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList('request_queue') ?? [];
    queue.add(task.toJsonString());
    prefs.setStringList('request_queue', queue);
    print("Task added to queue: ");
  }

  static Future run_queue() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList('request_queue') ?? [];
    List<Bgtask> task_list = queue
        .map((e) => Bgtask.fromJsonString(e))
        .toList();
    task_list.forEach((task) {
      print("Processing task: ${task.toJsonString()}");
    });
  }

  static Future<void> Send_req_to_server() async {
    print("Sending queued requests to server...");
  }
}
