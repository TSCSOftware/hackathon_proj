import 'dart:isolate';
import 'dart:math';
import 'dart:io';

import 'package:hackathon_proj/mobile/api/pb.dart';
import 'package:hackathon_proj/mobile/bg_engine/bgtask.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:http/http.dart' as http;

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
    for (var task in task_list) {
      // print("Processing task: ${task.toJsonString()}");
      bool is_success = false;
      if (task.task_type == 'file_upload') {
        is_success = await Upload_files_from_queue(task);
      } else {
        is_success = await Send_req_to_server(task);
      }

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
    }
    is_queue_running = false;
  }

  static Future<bool> Upload_files_from_queue(Bgtask task) async {
    print("Uploading files from queue...");
    final pb_admin = PocketBase(
      'http://test.otan.cc:8095',
      reuseHTTPClient: true,
    );

    List<String> filePaths = List<String>.from(task.body['filePaths']);
    List<http.MultipartFile> tempfilelist = [];

    for (var filePath in filePaths) {
      final file = File(filePath);
      if (await file.exists()) {
        tempfilelist.add(await http.MultipartFile.fromPath('files', file.path));
        print('Added to upload list: ${file.path}');
      } else {
        print('File not found: $filePath');
      }
    }

    if (tempfilelist.isEmpty) {
      print("No files to upload.");
      return true; // No files to upload, consider it a success to remove from queue.
    }

    try {
      await pb_admin.admins.authWithPassword("su@su.com", "su@su.com");
      final record = await pb_admin
          .collection('photos')
          .create(body: {"id": task.body['uuidxx']}, files: tempfilelist);
      print("Upload record created: ${record.id}");
      // Clean up copied files
      for (var filePath in filePaths) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          print('Deleted temp file: $filePath');
        }
      }
      return true;
    } catch (e) {
      print("Error uploading files: $e");
      return false;
    }
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
