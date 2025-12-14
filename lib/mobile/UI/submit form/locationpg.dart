import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
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

  Future<void> _useCurrent() async {
    try {
      final current = await Geolocator.getCurrentPosition (
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 5),
      );
      Navigator.of(context).pop(current);
    } catch (_) {
      setState(() {
        _error = 'Unable to get current location.';
      });
    }
  }

  Future<void> _useLastKnown() async {
    final last = await Geolocator.getLastKnownPosition();
    Navigator.of(context).pop(last ?? _zeroPosition());
  }

  void _useZero() {
    Navigator.of(context).pop(_zeroPosition());
  }

  void _useCustom() {
    try {
      final lat = double.parse(_latController.text.trim());
      final lon = double.parse(_lonController.text.trim());
      if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
        throw const FormatException('Out of range');
      }
      Navigator.of(context).pop(
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
      setState(() {
        _error = 'Please enter valid coordinates.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Location Type')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location not available. Choose how you want to proceed:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _useCurrent,
              icon: const Icon(Icons.my_location),
              label: const Text('Use Current Location'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _useZero,
              icon: const Icon(Icons.location_off),
              label: const Text('Send (0,0) without GPS'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _useLastKnown,
              icon: const Icon(Icons.history),
              label: const Text('Use Last Known Location'),
            ),
            const SizedBox(height: 16),
            const Text('Or enter a custom location'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Latitude (-90 to 90)',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _lonController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Longitude (-180 to 180)',
                    ),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: _useCustom,
                icon: const Icon(Icons.check),
                label: const Text('Use Custom Location'),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
