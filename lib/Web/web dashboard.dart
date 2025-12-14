import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:hackathon_proj/Web/live_data.dart';
import 'package:hackathon_proj/models/report.dart';
import 'package:hackathon_proj/mobile/api/file_upload.dart';

class WebDashboardPage extends StatefulWidget {
  const WebDashboardPage({Key? key}) : super(key: key);

  @override
  State<WebDashboardPage> createState() => _WebDashboardPageState();
}

class _WebDashboardPageState extends State<WebDashboardPage> {
  bool _sidebarOpen = true;
  final List<Report> _incoming = [];
  late final StreamSubscription<Report> _incomingSub;
  final StreamController<Report> _incomingController =
      StreamController.broadcast();
  // Map controller so we can programmatically add markers
  final MapController _mapController = MapController(
    initPosition: GeoPoint(latitude: 6.7056, longitude: 80.3847),
    areaLimit: BoundingBox(north: 47.8, east: 10.5, south: 45.8, west: 5.9),
  );
  // Keep a lookup from coordinates to their Request for quick info display
  final Map<String, Request> _requestByPoint = {};

  String _ptKey(double lat, double lon) =>
      '${lat.toStringAsFixed(6)},${lon.toStringAsFixed(6)}';

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
      // Ensure newest first
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Optionally clear old markers
      // await _mapController.removeAllMarkers();

      for (final req in list) {
        final status = req.status.toUpperCase();
        Color color;
        IconData iconData;
        if (status == 'PENDING') {
          color = const Color.fromARGB(255, 255, 1, 1);
          iconData = Icons.location_on;
        } else if (status == 'ACTION_TAKEN') {
          color = const Color.fromARGB(255, 105, 7, 128);
          iconData = Icons.build_circle;
        } else if (status == 'COMPLETED') {
          color = Colors.green;
          iconData = Icons.check_circle;
        } else {
          color = Colors.blueGrey;
          iconData = Icons.location_on;
        }

        await _mapController.addMarker(
          GeoPoint(latitude: req.lat, longitude: req.lon),
          markerIcon: MarkerIcon(icon: Icon(iconData, color: color, size: 48)),
          angle: 0,
        );
        _requestByPoint[_ptKey(req.lat, req.lon)] = req;
      }
    } catch (err) {
      // handle fetch error if needed
    }
  }

  @override
  void initState() {
    super.initState();
    // subscribe to simulated incoming stream
    //  timer that fetches from server every 10seconds
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      await _fetchAndPlotRequests();
    });

    _incomingSub = _incomingController.stream.listen((r) {
      setState(() => _incoming.insert(0, r));
    });

    // simulate live incoming reports every 5 seconds (demo)

    int idx = 0;
  }

  @override
  void dispose() {
    _incomingSub.cancel();
    _incomingController.close();
    super.dispose();
  }

  // parse coords like "6.9271° N, 79.8612° E" into lat,lon
  List<double>? _parseCoords(String coords) {
    if (coords.isEmpty) return null;
    final re = RegExp(r"(-?\d+\.?\d*)");
    final matches = re.allMatches(coords).toList();
    if (matches.length < 2) return null;
    double lat = double.parse(matches[0].group(0)!);
    double lon = double.parse(matches[1].group(0)!);
    // adjust sign if S/W present
    final s = coords.toUpperCase();
    if (s.contains('S')) lat = -lat;
    if (s.contains('W')) lon = -lon;
    return [lat, lon];
  }

  @override
  Widget build(BuildContext context) {
    const darkRed = Color(0xFF6B0000);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkRed,
        title: Row(
          children: [
            const Icon(Icons.dashboard, color: Colors.white),
            const SizedBox(width: 12),
            const Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // quick stats
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.fiber_new, color: Colors.white70, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${_incoming.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => setState(() {
                // refresh incoming (demo)
              }),
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: Row(
        children: [
          Expanded(
            child: OSMFlutter(
              controller: _mapController,

              osmOption: OSMOption(
                userTrackingOption: const UserTrackingOption(
                  enableTracking: true,
                  unFollowUser: false,
                ),
                zoomOption: const ZoomOption(
                  initZoom: 12,
                  minZoomLevel: 3,
                  maxZoomLevel: 19,
                  stepZoom: 1.0,
                ),
                userLocationMarker: UserLocationMaker(
                  personMarker: const MarkerIcon(
                    icon: Icon(
                      Icons.location_history_rounded,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                  directionArrowMarker: const MarkerIcon(
                    icon: Icon(Icons.double_arrow, size: 48),
                  ),
                ),
                roadConfiguration: const RoadOption(
                  roadColor: Colors.yellowAccent,
                ),
              ),

              onGeoPointClicked: (point) {
                final key = _ptKey(point.latitude, point.longitude);
                final req = _requestByPoint[key];
                if (req == null) return;
                showDialog(
                  context: context,
                  builder: (context) {
                    final date = DateTime.fromMillisecondsSinceEpoch(
                      req.timestamp,
                    ).toLocal();
                    return AlertDialog(
                      title: Text(req.incidentType.replaceAll('_', ' ')),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.place, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '(${req.lat.toStringAsFixed(4)}, ${req.lon.toStringAsFixed(4)})',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Status: ${req.status}'),
                          const SizedBox(height: 8),
                          Text('Severity: ${req.severity}'),
                          const SizedBox(height: 8),
                          Text(
                            'Details: ${req.additionalDetails}',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Time: ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: _sidebarOpen ? 450 : 0,
            child: _sidebarOpen ? LiveDataPage() : const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _sidebarOpen = !_sidebarOpen),
        child: const Icon(Icons.menu),
      ),
    );
  }
}
