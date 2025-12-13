//create empyt statefull widget
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:hackathon_proj/Web/live_data.dart';
import 'package:hackathon_proj/mobile/api/file_upload.dart';

class TestPage_web extends StatefulWidget {
  const TestPage_web({Key? key}) : super(key: key);

  @override
  State<TestPage_web> createState() => _TestPage_webState();
}

class _TestPage_webState extends State<TestPage_web> {
  final MapController mapController = MapController(
    initPosition: GeoPoint(latitude: 6.7056, longitude: 80.3847),
  );

  Future<void> _fetchAndPlotRequests() async {
    try {
      final records = await pb_admin.collection('requests').getFullList();
      final List<Request> list = records.map<Request>((r) {
        try {
          return Request.fromMap(r.toJson());
        } catch (_) {
          return Request(
            id: r.id ?? '',
            lon: 0,
            lat: 0,
            timestamp: 0,
            incidentType: '',
            status: '',
            additionalDetails: '',
            severity: 0,
            photoId: '',
          );
        }
      }).toList();
      // newest first
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Optionally clear existing markers before drawing new ones
      // await mapController.removeAllMarkers(); // uncomment if desired

      for (final req in list) {
        // Choose marker color/icon by status
        final String status = req.status.toLowerCase();
        Color color;
        IconData iconData;
        if (status == 'pending') {
          color = Colors.amber;
          iconData = Icons.location_on;
        } else if (status == 'resolved') {
          color = Colors.green;
          iconData = Icons.check_circle;
        } else if (status == 'in_progress' || status == 'processing') {
          color = Colors.orange;
          iconData = Icons.build_circle;
        } else {
          color = Colors.blueGrey;
          iconData = Icons.location_on;
        }

        await mapController.addMarker(
          GeoPoint(latitude: req.lat, longitude: req.lon),
          markerIcon: MarkerIcon(icon: Icon(iconData, color: color, size: 48)),
          angle: 0,
        );
      }
    } catch (err) {
      // You may show a snackbar/toast if needed
    }
  }

  @override
  void initState() {
    MapController controller = MapController(
      initPosition: GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
      areaLimit: BoundingBox(
        east: 10.4922941,
        north: 47.8084648,
        south: 45.817995,
        west: 5.9559113,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: () async {
              // Fetch from PocketBase and add status-based markers
              await _fetchAndPlotRequests();
            },
          ),
        ],
      ),
      body: OSMFlutter(
        controller: mapController,
        osmOption: OSMOption(zoomOption: ZoomOption(initZoom: 12)),
        onGeoPointLongPress: (point) {
          print("long press on $point");
        },
        onGeoPointClicked: (point) {
          // When a marker is clicked, show a popup with PointerInterceptor
          // showDialog(
          //   context: context,
          //   builder: (context) => PointerInterceptor(
          //     // The PointerInterceptor is crucial here for web platforms
          //     child: AlertDialog(
          //       title: Text('Marker Clicked'),
          //       content: Text('Location: ${point.latitude}, ${point.longitude}'),
          //       actions: [
          //         TextButton(
          //           // This button will work on web thanks to PointerInterceptor
          //           onPressed: () => Navigator.pop(context),
          //           child: Text('Close'),
          //         ),
          //       ],
          //     ),
          //   ),
          // );
        },
      ),
    );
  }
}
