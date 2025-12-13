import 'package:flutter/material.dart';
import 'package:hackathon_proj/mobile/UI/submit%20form/func.dart';
import 'package:hackathon_proj/mobile/api/pb.dart';
import 'package:hackathon_proj/mobile/bg_engine/bg.dart';
import 'package:hackathon_proj/mobile/bg_engine/bgtask.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Page')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('This is a test page'),
            ElevatedButton(
              onPressed: () {
                ApiService.login_withpass("test@test.com", "12345678");
              },
              child: Text('login'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                print("Logged out");
                // TODO alsonremove seciure storesg
              },
              child: Text("Logout"),
            ),

            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await create_request();
              },
              child: Text('send_req'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                var userid = await storage.read(key: "vv_id");
                var timestamp = DateTime.now().toIso8601String();
                final body = <String, dynamic>{
                  "user": userid,
                  "location": {"lon": 0, "lat": 0},
                  "timestamp": timestamp,
                  "incident_type": "LANDSLIDE",
                  "status": "PENDING",
                  "additional_details": "test",
                };
                var mytask = Bgtask(body: body);
                await Bg_engine.add_to_queue(mytask);
              },
              child: Text('add_queue'),
            ),
            ElevatedButton(
              onPressed: () async {
                await Bg_engine.run_queue();
              },
              child: Text('run_queue'),
            ),
          ],
        ),
      ),
    );
  }
}
