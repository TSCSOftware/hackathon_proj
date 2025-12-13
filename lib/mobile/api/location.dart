import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

Future<bool> ensureLocationEnabled(BuildContext context) async {
  final enabled = await Geolocator.isLocationServiceEnabled();
  if (!enabled) {
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Location required'),
        content: const Text(
          'Location services are disabled. Open settings to enable them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (open == true) {
      await Geolocator.openLocationSettings();
      // Give the user a moment to enable and return false so caller can retry
      return false;
    }
    return false;
  }
  return true;
}


//  final pos = await Geolocator.getCurrentPosition(
        // desiredAccuracy: LocationAccuracy.best,
      // );