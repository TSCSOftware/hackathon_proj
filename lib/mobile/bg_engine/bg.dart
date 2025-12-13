import 'dart:isolate';
import 'dart:math';

import 'package:hackathon_proj/mobile/api/pb.dart';
import 'package:hackathon_proj/mobile/bg_engine/bgtask.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

class Bg_engine {
  static void initialize() {
    print("Background engine initialized");
    // Add background tasks or services initialization here
  }

  static Future<void> add_to_queue(Bgtask task) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList('request_queue') ?? [];
    queue.add(task.toJsonString());
    prefs.setStringList('request_queue', queue);
    print("Task added to queue");
  }

  static bool is_queue_running = false;
  static Future run_queue() async {
    if (is_queue_running) {
      print("Queue is already running, skipping this run.");
      return;
    }
    is_queue_running = true;
    final prefs = await SharedPreferences.getInstance();
    List<String> queue = prefs.getStringList('request_queue') ?? [];
    List<String> succeedQueue =
        prefs.getStringList('succeed_request_queue') ?? [];
    List<Bgtask> task_list = queue
        .map((e) => Bgtask.fromJsonString(e))
        .toList();
    task_list.forEach((task) async {
      // print("Processing task: ${task.toJsonString()}");
      bool is_success = await Send_req_to_server(task);
      if (is_success) {
        // Remove from pending queue
        final serialized = task.toJsonString();
        queue.remove(serialized);
        await prefs.setStringList('request_queue', queue);

        // Append to succeed queue
        succeedQueue.add(serialized);
        await prefs.setStringList('succeed_request_queue', succeedQueue);

        // print("Task processed: moved to succeed_request_queue: $serialized");
      }
    });
    is_queue_running = false;
  }

  static Future<bool> Send_req_to_server(Bgtask task) async {
    print("Sending queued requests to server...");
    var userid = await storage.read(key: "vv_id");

    final record = await PB.collection('requests').create(body: task.body);

    if (record.id.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
