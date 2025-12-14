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

enum _FallbackChoice { zero, lastKnown, custom, cancel }

Future<_FallbackChoice> _chooseLocationFallback(
  BuildContext context, {
  String title = 'LOCATION_UNAVAILABLE',
  String message = 'Location not available. Choose how to proceed:',
}) async {
  final choice = await showDialog<_FallbackChoice>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(_FallbackChoice.zero),
            child: const Text('Send 0,0'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(_FallbackChoice.lastKnown),
            child: const Text('Use Last Known'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(_FallbackChoice.custom),
            child: const Text('Custom Location'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(_FallbackChoice.cancel),
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
  return choice ?? _FallbackChoice.cancel;
}

Future<Position?> _promptCustomLatLon(BuildContext context) async {
  final latController = TextEditingController();
  final lonController = TextEditingController();
  final result = await showDialog<Position>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
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
                  throw FormatException('Out of range');
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
                // keep dialog open; optionally show a simple error via SnackBar
              }
            },
            child: const Text('Use'),
          ),
        ],
      );
    },
  );
  latController.dispose();
  lonController.dispose();
  return result;
}

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
      final choice = await _chooseLocationFallback(
        context,
        title: 'LOCATION_DISABLED',
        message: 'Location services disabled. Choose a fallback option:',
      );
      if (choice == _FallbackChoice.zero) {
        pos = _zeroPosition();
      } else if (choice == _FallbackChoice.lastKnown) {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          pos = last;
        } else {
          pos = _zeroPosition();
        }
      } else if (choice == _FallbackChoice.custom) {
        final custom = await _promptCustomLatLon(context);
        if (custom != null) {
          pos = custom;
        } else {
          GotoPage(context, DashboardPage(), isReplace: true);
          return;
        }
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
      final choice = await _chooseLocationFallback(
        context,
        title: 'LOCATION_PERMISSION_DENIED',
        message: 'Permission denied. Choose a fallback option:',
      );
      if (choice == _FallbackChoice.zero) {
        pos = _zeroPosition();
      } else if (choice == _FallbackChoice.lastKnown) {
        final last = await Geolocator.getLastKnownPosition();
        pos = last ?? _zeroPosition();
      } else if (choice == _FallbackChoice.custom) {
        final custom = await _promptCustomLatLon(context);
        if (custom != null) {
          pos = custom;
        } else {
          GotoPage(context, DashboardPage(), isReplace: true);
          return;
        }
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
      final choice = await _chooseLocationFallback(context);
      if (choice == _FallbackChoice.zero) {
        pos = _zeroPosition();
      } else if (choice == _FallbackChoice.lastKnown) {
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
          pos = _zeroPosition();
        }
      } else if (choice == _FallbackChoice.custom) {
        final custom = await _promptCustomLatLon(context);
        if (custom != null) {
          pos = custom;
        } else {
          GotoPage(context, DashboardPage(), isReplace: true);
          return;
        }
      } else {
        GotoPage(context, DashboardPage(), isReplace: true);
        return;
      }
    } catch (e2) {
      print("Error obtaining getLastKnownPosition: $e2");
      final choice = await _chooseLocationFallback(
        context,
        title: 'LOCATION_ERROR',
        message: 'Unable to retrieve location. Choose a fallback option:',
      );
      if (choice == _FallbackChoice.zero) {
        pos = _zeroPosition();
      } else if (choice == _FallbackChoice.lastKnown) {
        final last = await Geolocator.getLastKnownPosition();
        pos = last ?? _zeroPosition();
      } else if (choice == _FallbackChoice.custom) {
        final custom = await _promptCustomLatLon(context);
        if (custom != null) {
          pos = custom;
        } else {
          GotoPage(context, DashboardPage(), isReplace: true);
          return;
        }
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
