import 'package:flutter/material.dart';
import 'package:hackathon_proj/mobile/bg_engine/bgtask.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubmittedReportsPage extends StatefulWidget {
  const SubmittedReportsPage({Key? key}) : super(key: key);

  @override
  State<SubmittedReportsPage> createState() => _SubmittedReportsPageState();
}

class _SubmittedReportsPageState extends State<SubmittedReportsPage> {
  List<Bgtask> _submitted = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadSubmitted);
  }

  Future<void> _loadSubmitted() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('succeed_request_queue') ?? [];
    setState(() {
      _submitted = list.map((e) => Bgtask.fromJsonString(e)).toList();
    });
  }

  Future<void> _deleteSubmitted(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('succeed_request_queue') ?? [];
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    await prefs.setStringList('succeed_request_queue', list);
    setState(() {
      _submitted.removeAt(index);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submitted Reports'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: _submitted.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No submitted reports',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _submitted.length,
                itemBuilder: (context, i) {
                  final t = _submitted[i];
                  final b = t.body;
                  final incident = (b['incident_type'] ?? 'Unknown').toString();
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
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
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
                                      fontWeight: FontWeight.bold,
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
                                  _buildDetailRow(
                                    'Severity:',
                                    severity,
                                    color: _getSeverityColor(severity),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    'When',
                                    DateFormat.yMMMd().add_jm().format(
                                      timestamp.toLocal(),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (coords.isNotEmpty)
                                    _buildDetailRow('Coords:', coords),
                                  if (details.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      'Details:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
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
                                  _deleteSubmitted(i);
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
                                      fontWeight: FontWeight.bold,
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
                                    color: _getSeverityColor(severity),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'SEV $severity',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildDetailRow(String title, String value, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
