import 'package:flutter/material.dart';
import 'package:hackathon_proj/mobile/bg_engine/bgtask.dart';
import 'package:hackathon_proj/models/report.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Reports')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _tasks.isEmpty
            ? const Center(child: Text('No pending reports'))
            : ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, i) {
                  final t = _tasks[i];
                  final b = t.body;
                  final incident = (b['incident_type'] ?? '').toString();
                  final severity = (b['severity'] ?? '').toString();
                  final details = (b['additional_details'] ?? '').toString();
                  final coords = b['location'] is Map
                      ? (b['location'] as Map).entries
                            .map((e) => '${e.key}:${e.value}')
                            .join(', ')
                      : '';
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                incident.isEmpty
                                    ? 'Unknown incident'
                                    : incident,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Severity $severity'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('When: ${t.timestamp.toLocal()}'),
                          const SizedBox(height: 8),
                          if (coords.isNotEmpty) Text('Coords: $coords'),
                          if (details.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(details),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text(
                                'Pending',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () => _deleteTask(i),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
