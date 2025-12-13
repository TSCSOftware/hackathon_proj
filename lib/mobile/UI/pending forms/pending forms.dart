import 'package:flutter/material.dart';
import 'package:hackathon_proj/mobile/bg_engine/bgtask.dart';
import 'package:hackathon_proj/models/report.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PendingFormsPage extends StatefulWidget {
  const PendingFormsPage({Key? key}) : super(key: key);

  @override
  State<PendingFormsPage> createState() => _PendingFormsPageState();
}

class _PendingFormsPageState extends State<PendingFormsPage> {
  List<Bgtask> _tasks = [];

  @override
  void initState() {
    super.initState();
    // Load queued tasks from SharedPreferences
    Future.microtask(_loadQueue);
  }

  Future<void> _loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList('request_queue') ?? [];
    setState(() {
      _tasks = queue.map((e) => Bgtask.fromJsonString(e)).toList();
    });
  }

  Future<void> _deleteTask(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList('request_queue') ?? [];
    if (index < 0 || index >= queue.length) return;
    queue.removeAt(index);
    await prefs.setStringList('request_queue', queue);
    setState(() {
      _tasks.removeAt(index);
    });
  }

  Color _getSeverityColor(String severityString) {
    final severity = int.tryParse(severityString);
    switch (severity) {
      case 5:
        return Colors.red.shade700;
      case 4:
        return Colors.orange.shade700;
      case 3:
        return Colors.yellow.shade700;
      default:
        return Colors.green.shade700;
    }
  }

  IconData _getIncidentIcon(String incident) {
    switch (incident.toLowerCase()) {
      case 'fire':
        return Icons.local_fire_department;
      case 'medical':
        return Icons.medical_services;
      case 'accident':
        return Icons.car_crash;
      case 'crime':
        return Icons.local_police;
      default:
        return Icons.report_problem;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkRed = Color(0xFF6B0000);
    const Color lightRed = Color(0xFFE53935);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: darkRed,
        foregroundColor: Colors.white,
        title: const Text(
          'Pending Reports',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFFFF9999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _tasks.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No pending reports',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, i) {
                  final t = _tasks[i];
                  final b = t.body;
                  final incident = (b['incident_type'] ?? 'Unknown').toString();
                  if (incident=='Unknown'){ {
                    //remove invalid task
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _deleteTask(i);
                      setState(() {
                        
                      });
                    });
                  }}
                  final severity = (b['severity'] ?? '0').toString();
                  final details = (b['additional_details'] ?? '').toString();
                  final coords = b['location'] is Map
                      ? (b['location'] as Map).entries
                            .map(
                              (e) =>
                                  '${e.key}: ${double.tryParse(e.value.toString())?.toStringAsFixed(4) ?? e.value}',
                            )
                            .join(', ')
                      : '';
                  final timestamp = t.timestamp;

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Row(
                              children: [
                                Icon(
                                  _getIncidentIcon(incident),
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    incident.isEmpty
                                        ? 'Unknown incident'
                                        : incident,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Severity:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        severity,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: _getSeverityColor(severity),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'When',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          DateFormat.yMMMd().add_jm().format(
                                            timestamp.toLocal(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (coords.isNotEmpty) ...[
                                    Text(
                                      'Coords:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(coords),
                                  ],
                                  if (details.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      'Details:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(details),
                                  ],
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteTask(i);
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: _getSeverityColor(
                                severity,
                              ).withOpacity(0.15),
                              child: Icon(
                                _getIncidentIcon(incident),
                                color: _getSeverityColor(severity),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    incident,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat.yMMMd().add_jm().format(
                                      timestamp.toLocal(),
                                    ),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade600,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'PENDING',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    ));
  }
}