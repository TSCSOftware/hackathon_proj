import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:hackathon_proj/models/report.dart';

class WebDashboardPage extends StatefulWidget {
  const WebDashboardPage({Key? key}) : super(key: key);

  @override
  State<WebDashboardPage> createState() => _WebDashboardPageState();
}

class _WebDashboardPageState extends State<WebDashboardPage> {
  bool _sidebarOpen = true;
  final List<Report> _incoming = [];
  late final StreamSubscription<Report> _incomingSub;
  final StreamController<Report> _incomingController = StreamController.broadcast();
  // Map controller so we can programmatically add markers
  final MapController _mapController = MapController(
    initPosition: GeoPoint(latitude: 6.7056, longitude: 80.3847),
    areaLimit: BoundingBox(north: 47.8, east: 10.5, south: 45.8, west: 5.9)
  );

  @override
  void initState() {
    super.initState();
    // subscribe to simulated incoming stream
    _incomingSub = _incomingController.stream.listen((r) {
      setState(() => _incoming.insert(0, r));
    });

    // simulate live incoming reports every 5 seconds (demo)
    var demoReports = [
      Report(id: 'r6', incident: 'New flash flood', severity: 4, coords: '6.9300° N, 79.8600° E', timestamp: '2025-12-13 10:02', details: 'Rapid water rise near bridge.'),
      Report(id: 'r7', incident: 'Minor fire outbreak', severity: 2, coords: '6.9250° N, 79.8550° E', timestamp: '2025-12-13 10:05', details: 'Contained by locals.'),
      Report(id: 'r8', incident: 'Road block - debris', severity: 3, coords: '6.9220° N, 79.8480° E', timestamp: '2025-12-13 10:12', details: 'Cleanup requested.'),
    ];

    int idx = 0;
    Timer.periodic(const Duration(seconds: 5), (t) {
      if (idx >= demoReports.length) return;
      _incomingController.add(demoReports[idx++]);
    });

    // Add a marker at the requested fixed location after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _mapController.addMarker(
          GeoPoint(latitude: 6.7056, longitude: 80.3847),
        );
      } catch (_) {
        // ignore errors if controller not ready
      }
    });
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
            const Text('Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const Spacer(),
            // quick stats
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Icon(Icons.fiber_new, color: Colors.white70, size: 18),
                  const SizedBox(width: 6),
                  Text('${_incoming.length}', style: const TextStyle(color: Colors.white)),
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
        icon: Icon(
          Icons.double_arrow,
          size: 48,
        ),
      ),
    ),
    roadConfiguration: const RoadOption(
      roadColor: Colors.yellowAccent,
    ),
  ),
)
          ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: _sidebarOpen ? 380 : 0,
            child: _sidebarOpen
                ? Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              const Expanded(child: Text('Live Incoming Reports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                              Chip(label: Text('${_incoming.length} new'), backgroundColor: Colors.red[50]),
                              const SizedBox(width: 8),
                              Chip(label: Text('${pendingReports.length} pending'), backgroundColor: Colors.orange[50]),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => setState(() => _sidebarOpen = false),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(child: Container()),
                              OutlinedButton.icon(
                                onPressed: () => setState(() => _incoming.clear()),
                                icon: const Icon(Icons.clear),
                                label: const Text('Clear Incoming'),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _incoming.length + pendingReports.length,
                            itemBuilder: (context, i) {
                              final bool isIncoming = i < _incoming.length;
                              final r = isIncoming ? _incoming[i] : pendingReports[i - _incoming.length];
                              final color = r.severity >= 4 ? Colors.red : (r.severity == 3 ? Colors.orange : Colors.blue);
                              final status = isIncoming ? 'Incoming' : 'Pending';
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                leading: CircleAvatar(backgroundColor: color, child: Text(r.severity.toString(), style: const TextStyle(color: Colors.white))),
                                title: Text(r.incident, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text('${r.timestamp} • ${r.coords}'),
                                trailing: null,
                                onTap: () {},
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
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
