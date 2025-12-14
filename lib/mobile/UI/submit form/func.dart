import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Location Unavailable'),
        content: const Text('Choose how to proceed:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('zero'),
            child: const Text('Send 0,0'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('last'),
            child: const Text('Use Last Known'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('custom'),
            child: const Text('Custom Location'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('cancel'),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (choice == 'zero') {
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
    } else if (choice == 'last') {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return last;
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
    } else if (choice == 'custom') {
      final latController = TextEditingController();
      final lonController = TextEditingController();
      final custom = await showDialog<Position>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Enter Custom Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: latController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Latitude (-90 to 90)',
                ),
              ),
              TextField(
                controller: lonController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Longitude (-180 to 180)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                try {
                  final lat = double.parse(latController.text.trim());
                  final lon = double.parse(lonController.text.trim());
                  if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
                    throw const FormatException('Out of range');
                  }
                  Navigator.of(ctx).pop(
                    Position(
                      latitude: lat,
                      longitude: lon,
                      timestamp: DateTime.now(),
                      accuracy: 0,
                      altitude: 0,
                      heading: 0,
                      speed: 0,
                      altitudeAccuracy: 0,
                      headingAccuracy: 0,
                      speedAccuracy: 0,
                    ),
                  );
                } catch (_) {
                  // Invalid input: do nothing to keep dialog open
                }
              },
              child: const Text('Use'),
            ),
          ],
        ),
      );
      latController.dispose();
      lonController.dispose();
      if (custom != null) return custom;
      // fall back to cancel flow
    }

    // Cancel or invalid selection: default to (0,0)
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
