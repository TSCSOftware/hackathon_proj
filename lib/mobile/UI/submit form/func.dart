import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hackathon_proj/main.dart';
import 'package:hackathon_proj/mobile/UI/dashbord/ui.dart';
import 'package:hackathon_proj/mobile/api/pb.dart';
import 'package:hackathon_proj/mobile/bg_engine/bg.dart';
import 'package:hackathon_proj/mobile/bg_engine/bgtask.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

Future create_request() async {}

Future<bool> _confirmForceSend(
  BuildContext context, {
  String title = 'LOCATION_UNAVAILABLE',
  String message =
      'Unable to get your location. Do you want to force send to the service team with location set to (0,0)?',
}) async {
  final res = await QuickAlert.show(
    context: context,
    type: QuickAlertType.confirm,
    title: title,
    text: message,
    confirmBtnText: 'Force Send',
    cancelBtnText: 'Cancel',
  );
  return res == true;
}

Position _zeroPosition() => Position(
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

Future<void> _enqueueRequest({
  required Position pos,
  required String incident_type,
  required String additional_details,
  required int severity,
  required String photo_id,
}) async {
  final userid = await storage.read(key: "vv_id");
  final timestamp = DateTime.now().millisecondsSinceEpoch;
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

Future Submit_request({
  required BuildContext context,
  required String incident_type,
  required String additional_details,
  required int severity,
  required String photo_id,
}) async {
  Position? pos;

  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      final proceed = await _confirmForceSend(
        context,
        title: 'LOCATION_DISABLED',
        message: 'Location services are disabled. Force send with (0,0)?',
      );
      if (proceed) {
        pos = _zeroPosition();
      } else {
        GotoPage(context, DashboardPage(), isReplace: true);
        return;
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      final proceed = await _confirmForceSend(
        context,
        title: 'LOCATION_PERMISSION_DENIED',
        message: 'Permission denied. Force send with (0,0)?',
      );
      if (proceed) {
        pos = _zeroPosition();
      } else {
        GotoPage(context, DashboardPage(), isReplace: true);
        return;
      }
    }

    if (pos == null) {
      pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 30),
      );
    }
    await _enqueueRequest(
      pos: pos!,
      incident_type: incident_type,
      additional_details: additional_details,
      severity: severity,
      photo_id: photo_id,
    );
  } catch (e) {
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        pos = last;
        await QuickAlert.show(
          context: context,
          title: 'GPS_COMMUNICATION_LOST',
          text: 'Used last known location.',
          type: QuickAlertType.error,
        );
      } else {
        final shouldForce = await _confirmForceSend(context);
        if (shouldForce) {
          pos = _zeroPosition();
        } else {
          GotoPage(context, DashboardPage(), isReplace: true);
          return;
        }
      }
    } catch (e2) {
      print("Error obtaining getLastKnownPosition: $e2");
      final proceed = await _confirmForceSend(
        context,
        title: 'LOCATION_ERROR',
        message: 'Unable to retrieve location. Force send with (0,0)?',
      );
      if (proceed) {
        pos = _zeroPosition();
      } else {
        GotoPage(context, DashboardPage(), isReplace: true);
        return;
      }
    }
  }

  // Final enqueue using resolved position
  await _enqueueRequest(
    pos: pos!,
    incident_type: incident_type,
    additional_details: additional_details,
    severity: severity,
    photo_id: photo_id,
  );
}
