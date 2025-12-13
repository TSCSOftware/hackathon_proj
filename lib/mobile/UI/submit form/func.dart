import 'package:hackathon_proj/mobile/api/pb.dart';

Future create_request() async {
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

  final record = await PB.collection('requests').create(body: body);
  print(record.id);
}
