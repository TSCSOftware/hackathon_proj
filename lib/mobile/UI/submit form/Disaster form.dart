import 'package:flutter/material.dart';
import 'package:hackathon_proj/mobile/UI/widgets/online_indicator.dart';

class DisasterFormPage extends StatefulWidget {
  const DisasterFormPage({Key? key}) : super(key: key);

  @override
  State<DisasterFormPage> createState() => _DisasterFormPageState();
}

class _DisasterFormPageState extends State<DisasterFormPage> {
  String _incident = '';
  int _severity = 1;
  String _coords = '';
  String _timestamp = '';
  final TextEditingController _detailsController = TextEditingController();

  void _pickIncident(String id) => setState(() => _incident = id);
  void _setSeverity(int s) => setState(() => _severity = s);
  void _getCoords() => setState(() => _coords = '6.9271° N, 79.8612° E');
  void _setTimestamp() =>
      setState(() => _timestamp = DateTime.now().toIso8601String());

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color darkRed = Color(0xFF6B0000);
    const Color lightRed = Color(0xFFE53935);

    Widget incidentBox({
      required IconData icon,
      required String label,
      required String id,
    }) {
      final selected = _incident == id;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _pickIncident(id),
          child: Ink(
            decoration: BoxDecoration(
              color: selected ? darkRed : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? darkRed : Colors.black12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: selected
                      ? Colors.white.withOpacity(0.12)
                      : Colors.white,
                  radius: 28,
                  child: Icon(
                    icon,
                    size: 28,
                    color: selected ? Colors.white : darkRed,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : darkRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Disaster  Report',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: darkRed,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {},
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF6B0000)),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Color(0xFFFF9999)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Incident type container
              OnlineIndicator(asCard: true),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Incident Type',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: incidentBox(
                              icon: Icons.landscape,
                              label: 'Landslide',
                              id: 'landslide',
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: incidentBox(
                              icon: Icons.water,
                              label: 'Flood',
                              id: 'flood',
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: incidentBox(
                              icon: Icons.block,
                              label: 'Road block',
                              id: 'roadblock',
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: incidentBox(
                              icon: Icons.power_off,
                              label: 'Power line down',
                              id: 'powerdown',
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: incidentBox(
                              icon: Icons.device_unknown,
                              label: 'Other',
                              id: 'other',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Severity container
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Severity',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(5, (i) {
                              final val = i + 1;
                              final selected = _severity == val;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(
                                    '$val',
                                    style: TextStyle(
                                      color: selected ? Colors.white : darkRed,
                                    ),
                                  ),
                                  selected: selected,
                                  onSelected: (_) => _setSeverity(val),
                                  selectedColor: darkRed,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '1=Critical                               5=Low threat',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // GPS coordinates
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GPS Coordinates (lat, long)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_coords.isEmpty ? '-' : _coords),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _getCoords,
                          child: const Text('Get Coordinates'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Timestamp
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Timestamp',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_timestamp.isEmpty ? '-' : _timestamp),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _setTimestamp,
                          child: const Text('Set Now'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Photos optional
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Photos (Optional)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add_a_photo),
                            label: const Text('Add Photos'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Additional details
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Additional details',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _detailsController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText:
                              'Enter any extra details about the incident...',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Submit button (green)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Simple submit action: show a snackbar and clear details
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Form submitted')),
                    );
                    setState(() {
                      _detailsController.clear();
                    });
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Footer (same as dashboard)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Disaster Mangement',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
