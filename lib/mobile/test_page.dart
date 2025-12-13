import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hackathon_proj/mobile/api/pb.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String _coords = '-';
  bool _gettingLocation = false;

  @override
  void initState() {
    super.initState();
    // Attempt to auto-fetch location when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocation(auto: true);
    });
  }

  Future<bool> _ensureLocationEnabled() async {
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

  Future<void> _fetchLocation({bool auto = false}) async {
    setState(() => _gettingLocation = true);
    try {
      final enabled = await _ensureLocationEnabled();
      if (!enabled) {
        setState(() {
          _coords = auto ? '-' : 'Location services disabled';
          _gettingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _coords = 'Permission denied';
          _gettingLocation = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        _coords =
            '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
      });
    } catch (e) {
      setState(() {
        _coords = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() => _gettingLocation = false);
    }
  }

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
