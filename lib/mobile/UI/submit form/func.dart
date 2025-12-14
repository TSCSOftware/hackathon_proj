import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hackathon_proj/mobile/UI/submit%20form/locationpg.dart';
import 'package:hackathon_proj/mobile/api/pb.dart';
import 'package:hackathon_proj/mobile/bg_engine/bg.dart';
import 'package:hackathon_proj/mobile/bg_engine/bgtask.dart';

Future<void> Submit_request({
  required BuildContext context,
  required String incident_type,
  required String additional_details,
  required int severity,
  required String photo_id,
}) async {
  Position? pos = await Getgps(context);
  final userid = await storage.read(key: "vv_id");
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final body = <String, dynamic>{
    "user": userid,
    "location": {"lon": pos!.longitude, "lat": pos.latitude},
    "timestamp": timestamp,
    "incident_type": incident_type,
    "status": "PENDING",
    "additional_details": additional_details,
    "severity": severity,
    "photo_id": photo_id,
  };
  await Bg_engine.add_to_queue(Bgtask(body: body));
}

Future<Position> Getgps(BuildContext context) async {
  try {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      timeLimit: const Duration(seconds: 5),
    );
  } catch (e) {
    // Navigate to selection page to choose location source
    final Position? selection = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LocationSelectionPage()));
    if (selection != null) return selection;
    // Default to 0,0 if user cancels
    return Position(
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
  }
}
