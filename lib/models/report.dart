class Report {
  final String id;
  final String incident;
  final int severity;
  final String coords;
  final String timestamp;
  final String details;

  Report({
    required this.id,
    required this.incident,
    required this.severity,
    required this.coords,
    required this.timestamp,
    required this.details,
  });
}

// Simple in-memory pending list for UI-only usage
final List<Report> pendingReports = [
  Report(
    id: 'r1',
    incident: 'Flooding near river bank',
    severity: 3,
    coords: '6.9271° N, 79.8612° E',
    timestamp: '2025-12-13 09:12',
    details: 'Water level rising, several homes affected.',
  ),
  Report(
    id: 'r2',
    incident: 'Landslide blocking road',
    severity: 4,
    coords: '6.9319° N, 79.8478° E',
    timestamp: '2025-12-12 16:45',
    details: 'Large landslide; vehicles trapped. Immediate help required.',
  ),
  Report(
    id: 'r3',
    incident: 'Fire in market area',
    severity: 5,
    coords: '6.9275° N, 79.8620° E',
    timestamp: '2025-12-11 20:30',
    details: 'Active fire spreading across stalls; smoke visible for miles.',
  ),
  Report(
    id: 'r4',
    incident: 'Power outage widespread',
    severity: 2,
    coords: '',
    timestamp: '2025-12-10 07:05',
    details: 'Neighborhood without power since early morning.',
  ),
  Report(
    id: 'r5',
    incident: 'Collapsed bridge (minor)',
    severity: 4,
    coords: '6.9200° N, 79.8500° E',
    timestamp: '2025-12-09 14:20',
    details: 'Partial collapse, one lane still passable with caution.',
  ),
];

// Simple in-memory submitted list for UI-only usage
final List<Report> submittedReports = [];
void addPending(Report r) => pendingReports.insert(0, r);

bool sendReport(Report r) {
  final removed = pendingReports.remove(r);
  if (removed) {
    // move to submitted list for display
    submittedReports.insert(0, r);
  }
  return removed;
}

void removePending(Report r) => pendingReports.remove(r);
