import 'package:flutter/material.dart';
import 'package:hackathon_proj/mobile/api/file_upload.dart';
import 'package:hackathon_proj/mobile/api/pb.dart';

class IncidentViewPage extends StatefulWidget {
  final String id;
  final double lon;
  final double lat;
  final int timestamp;
  final String incidentType;
  final String status;
  final String additionalDetails;
  final int severity;
  final String photoId;

  const IncidentViewPage({
    Key? key,
    required this.id,
    required this.lon,
    required this.lat,
    required this.timestamp,
    required this.incidentType,
    required this.status,
    required this.additionalDetails,
    required this.severity,
    required this.photoId,
  }) : super(key: key);

  @override
  State<IncidentViewPage> createState() => _IncidentViewPageState();
}

class _IncidentViewPageState extends State<IncidentViewPage> {
  late String _status;
  bool _updating = false;
  String? _photoUrl;
  List<String> _photoUrls = [];

  Color _severityColor(int s) {
    if (s >= 75) return Colors.red.shade700;
    if (s >= 40) return Colors.orange.shade700;
    return Colors.green.shade600;
  }

  @override
  void initState() {
    super.initState();
    print(widget.photoId);
    _status = widget.status;
    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    if (widget.photoId.isEmpty) return;
    try {
      final rec = await pb_admin.collection('photos').getOne(widget.photoId);
      final data = rec.toJson();
      // PocketBase record with files: [<filename>, ...]
      final filesField = data['files'];
      final List<String> filenames = [];
      if (filesField is List) {
        for (final f in filesField) {
          if (f is String && f.isNotEmpty) filenames.add(f);
        }
      }
      if (filenames.isEmpty) {
        for (final key in ['file', 'image', 'photo', 'picture']) {
          final val = data[key];
          if (val is String && val.isNotEmpty) {
            filenames.add(val);
            break;
          }
        }
      }
      if (filenames.isNotEmpty) {
        final collectionName = rec.collectionName ?? 'photos';
        final urls = filenames
            .map(
              (fn) =>
                  "${pb_admin.baseUrl}/api/files/$collectionName/${rec.id}/$fn",
            )
            .toList();
        if (mounted)
          setState(() {
            _photoUrls = urls;
            _photoUrl = urls.first;
          });
      }
    } catch (object) {
      print(object);
      // ignore loading errors; keep placeholder
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _updating = true);
    try {
      await pb_admin
          .collection('requests')
          .update(widget.id, body: {'status': newStatus});
      setState(() => _status = newStatus);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Status updated to $newStatus')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      widget.timestamp,
    ).toLocal();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.incidentType.replaceAll('_', ' ')),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Chip(
              label: Text(_status),
              backgroundColor: _status.toLowerCase() == 'pending'
                  ? Colors.yellow.shade100
                  : _status.toLowerCase() == 'completed'
                  ? Colors.green.shade50
                  : Colors.grey.shade100,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo / media area
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 220,
                color: Colors.grey.shade200,
                child: _photoUrl == null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_camera_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No photo attached',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      )
                    : Image.network(
                        _photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Unable to load photo',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            if (_photoUrls.isNotEmpty)
              SizedBox(
                height: 78,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photoUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final url = _photoUrls[i];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _photoUrl = url);
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            insetPadding: const EdgeInsets.all(16),
                            child: InteractiveViewer(
                              minScale: 0.8,
                              maxScale: 4,
                              child: Image.network(url, fit: BoxFit.contain),
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 78,
                          color: Colors.grey.shade100,
                          child: Image.network(url, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),

            // Key info row
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _severityColor(widget.severity),
                  child: Text(
                    '${widget.severity}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.incidentType.replaceAll('_', ' '),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.toLocal()}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),

            const SizedBox(height: 16),

            // Details
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Details',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.additionalDetails),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.place, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text('Location'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Latitude: ${widget.lat.toStringAsFixed(6)}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Text(
                      'Longitude: ${widget.lon.toStringAsFixed(6)}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.report_problem,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text('Incident Type'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(widget.incidentType.replaceAll('_', ' ')),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Map placeholder
            Text('Map', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: Text(
                  'Map placeholder\n(${widget.lat.toStringAsFixed(4)}, ${widget.lon.toStringAsFixed(4)})',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Status selector & actions
            Text(
              'Update Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('PENDING'),
                  selected: _status == 'PENDING',
                  onSelected: (sel) => sel ? _updateStatus('PENDING') : null,
                ),
                ChoiceChip(
                  label: const Text('ACTION_TAKEN'),
                  selected: _status == 'ACTION_TAKEN',
                  onSelected: (sel) =>
                      sel ? _updateStatus('ACTION_TAKEN') : null,
                ),
                ChoiceChip(
                  label: const Text('COMPLETED'),
                  selected: _status == 'COMPLETED',
                  onSelected: (sel) => sel ? _updateStatus('COMPLETED') : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _updating
                        ? null
                        : () => _updateStatus('COMPLETED'),
                    icon: const Icon(Icons.check_circle_outline),
                    label: _updating
                        ? const Text('Updating...')
                        : const Text('Mark Completed'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _updating ? null : () {},
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
