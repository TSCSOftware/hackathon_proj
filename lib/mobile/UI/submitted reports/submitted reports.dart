import 'package:flutter/material.dart';
import 'package:hackathon_proj/models/report.dart';

class SubmittedReportsPage extends StatefulWidget {
  const SubmittedReportsPage({Key? key}) : super(key: key);

  @override
  State<SubmittedReportsPage> createState() => _SubmittedReportsPageState();
}

class _SubmittedReportsPageState extends State<SubmittedReportsPage> {
  @override
  Widget build(BuildContext context) {
    final submitted = submittedReports;
    return Scaffold(
      appBar: AppBar(title: const Text('Submitted Reports')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: submitted.isEmpty
            ? const Center(child: Text('No submitted reports'))
            : ListView.builder(
                itemCount: submitted.length,
                itemBuilder: (context, i) {
                  final r = submitted[i];
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
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // simple read-only page: show details in dialog
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(r.incident),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Severity: ${r.severity}'),
                                          const SizedBox(height: 8),
                                          Text('When: ${r.timestamp}'),
                                          const SizedBox(height: 8),
                                          if (r.coords.isNotEmpty) Text('Coords: ${r.coords}'),
                                          const SizedBox(height: 8),
                                          if (r.details.isNotEmpty) Text(r.details),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                                    ],
                                  ),
                                );
                              },
                              child: const Text('View'),
                            ),
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
