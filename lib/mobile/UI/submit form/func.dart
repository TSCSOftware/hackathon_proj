import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hackathon_proj/mobile/api/pb.dart';
import 'package:hackathon_proj/mobile/bg_engine/bg.dart';
import 'package:hackathon_proj/mobile/bg_engine/bgtask.dart';

Future create_request() async {}

Future Submit_request({
  required BuildContext context,
  required String incident_type,
  required String additional_details,
  required int severity,
  required String photo_id,
}) async {
  Position pos = Position(
    latitude: 0,
    longitude: 0,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    heading: 0,
    speed: 0,
    altitudeAccuracy: 0,
    headingAccuracy: 0,
    speedAccuracy: 0,
  );
  try {
    Future.delayed(Duration.zero, () async {
      var pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: Duration(seconds: 300),
      );
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Error getting location: $e. Using default (0,0). GPS might be disabled.",
        ),
      ),
    );
  }

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
