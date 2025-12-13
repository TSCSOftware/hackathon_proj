import 'package:flutter/material.dart';
import 'package:hackathon_proj/mobile/api/file_upload.dart';
import 'view_incident.dart';

/// A small model that matches the PocketBase `requests` record shape used.
class Request {
  final String id;
  final double lon;
  final double lat;
  final int timestamp; // epoch millis
  final String incidentType;
  final String status;
  final String additionalDetails;
  final int severity;
  final String photoId;

  Request({
    required this.id,
    required this.lon,
    required this.lat,
    required this.timestamp,
    required this.incidentType,
    required this.status,
    required this.additionalDetails,
    required this.severity,
    required this.photoId,
  });

  factory Request.fromMap(Map<String, dynamic> m) {
    final loc = m['location'] ?? {};
    return Request(
      id: (m['id'] == null) ? '' : m['id'].toString(),
      lon: (loc['lon'] ?? 0).toDouble(),
      lat: (loc['lat'] ?? 0).toDouble(),
      timestamp: (m['timestamp'] ?? 0) is int
          ? m['timestamp']
          : int.tryParse('${m['timestamp']}') ?? 0,
      incidentType: (m['incident_type'] == null)
          ? ''
          : m['incident_type'].toString(),
      status: (m['status'] == null) ? '' : m['status'].toString(),
      additionalDetails: (m['additional_details'] == null)
          ? ''
          : m['additional_details'].toString(),
      severity: (m['severity'] ?? 0) is int
          ? m['severity']
          : int.tryParse('${m['severity']}') ?? 0,
      photoId: (m['photo_id'] == null) ? '' : m['photo_id'].toString(),
    );
  }
}

/// A beautiful, modern card to display a `Request`.
class RequestCard extends StatelessWidget {
  final Request request;
  final VoidCallback? onTap;

  const RequestCard({Key? key, required this.request, this.onTap})
    : super(key: key);

  Color _severityColor(int s) {
    if (s >= 75) return Colors.red.shade700;
    if (s >= 40) return Colors.orange.shade700;
    return Colors.green.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      request.timestamp,
    ).toLocal();
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: _severityColor(request.severity),
                child: Text(
                  '${request.severity}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            request.incidentType.replaceAll('_', ' '),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(request.status),
                          backgroundColor:
                              request.status.toLowerCase() == 'pending'
                              ? Colors.yellow.shade100
                              : request.status.toLowerCase() == 'resolved'
                              ? Colors.green.shade50
                              : Colors.grey.shade100,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      request.additionalDetails,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.place, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          '(${request.lat.toStringAsFixed(4)}, ${request.lon.toStringAsFixed(4)})',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Right thumbnail / photo placeholder
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade100,
                ),
                child: request.photoId.isNotEmpty
                    ? Icon(Icons.photo, color: Colors.grey[700])
                    : Icon(
                        Icons.photo_camera_outlined,
                        color: Colors.grey[400],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Demo page that shows a list of `RequestCard`s and contains
/// placeholder comments for PocketBase subscription handling.
class LiveDataPage extends StatefulWidget {
  const LiveDataPage({Key? key}) : super(key: key);

  @override
  State<LiveDataPage> createState() => _LiveDataPageState();
}

class _LiveDataPageState extends State<LiveDataPage> {
  final List<Request> _requests = [];

  bool _subscribed = false;

  @override
  void initState() {
    super.initState();
    _loadInitialAndSubscribe();
  }

  Future<void> _loadInitialAndSubscribe() async {
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
      // Ensure newest requests are shown first
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      setState(() {
        _requests
          ..clear()
          ..addAll(list);
      });
    } catch (err) {
      // optionally log fetch error
    }

    try {
      pb_admin.collection('requests').subscribe('*', (e) {
        try {
          final action = e.action?.toString() ?? '';
          if (e.record == null) return;
          final r = Request.fromMap(e.record!.toJson());
          setState(() {
            if (action == 'create') {
              if (!_requests.any((x) => x.id == r.id)) _requests.insert(0, r);
            } else if (action == 'update') {
              final idx = _requests.indexWhere((x) => x.id == r.id);
              if (idx >= 0) {
                _requests[idx] = r;
              } else {
                _requests.insert(0, r);
              }
            } else if (action == 'delete') {
              _requests.removeWhere((x) => x.id == r.id);
            }
            // Keep list ordered by latest timestamp at the top
            _requests.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          });
        } catch (_) {}
      });
      _subscribed = true;
    } catch (_) {
      // subscribe failed
    }
  }

  @override
  void dispose() {
    if (_subscribed) {
      try {
        pb_admin.collection('requests').unsubscribe();
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Requests')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ListView.separated(
          itemCount: _requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final r = _requests[i];
            return RequestCard(
              request: r,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => IncidentViewPage(
                      id: r.id,
                      lon: r.lon,
                      lat: r.lat,
                      timestamp: r.timestamp,
                      incidentType: r.incidentType,
                      status: r.status,
                      additionalDetails: r.additionalDetails,
                      severity: r.severity,
                      photoId: r.photoId,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
