import 'package:geolocator/geolocator.dart';
import 'package:hackathon_proj/mobile/api/pb.dart';
import 'package:hackathon_proj/mobile/bg_engine/bg.dart';
import 'package:hackathon_proj/mobile/bg_engine/bgtask.dart';

Future create_request() async {}

Future Submit_request({
  required String incident_type,
  required String additional_details,
  required int severity,
  required String photo_id,
}) async {
  var pos = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.best,
  );

  var userid = await storage.read(key: "vv_id");
  var timestamp = DateTime.now().millisecondsSinceEpoch;

  final body = <String, dynamic>{
    "user": userid,
    "location": {"lon": pos.longitude, "lat": pos.latitude},
    "timestamp": timestamp,
    "incident_type": incident_type,
    "status": "PENDING",
    "additional_details": additional_details,
    "severity": severity,
    "photo_id": photo_id,
  };

  Bg_engine.add_to_queue(Bgtask(body: body));
}
