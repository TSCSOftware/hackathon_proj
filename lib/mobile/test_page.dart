import 'package:flutter/material.dart';
import 'package:hackathon_proj/mobile/api/pb.dart';

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
            ElevatedButton(onPressed: () async {}, child: Text('tt')),
          ],
        ),
      ),
    );
  }
}
