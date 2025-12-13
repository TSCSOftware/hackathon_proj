import 'package:flutter/material.dart';
import 'package:hackathon_proj/models/report.dart';

class PendingFormsPage extends StatefulWidget {
  const PendingFormsPage({Key? key}) : super(key: key);

  @override
  State<PendingFormsPage> createState() => _PendingFormsPageState();
}

class _PendingFormsPageState extends State<PendingFormsPage> {
  @override
  Widget build(BuildContext context) {
    final pending = pendingReports;
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Reports')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: pending.isEmpty
            ? const Center(child: Text('No pending reports'))
            : ListView.builder(
                itemCount: pending.length,
                itemBuilder: (context, i) {
                  final r = pending[i];
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
                              Text(r.incident, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Severity ${r.severity}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('When: ${r.timestamp}'),
                          const SizedBox(height: 8),
                          if (r.coords.isNotEmpty) Text('Coords: ${r.coords}'),
                          if (r.details.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(r.details),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('Pending', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () {
                                  removePending(r);
                                  setState(() {});
                                },
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          )
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
