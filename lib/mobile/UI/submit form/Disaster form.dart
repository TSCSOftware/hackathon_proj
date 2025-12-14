import 'package:flutter/material.dart';
import 'package:hackathon_proj/main.dart';
import 'package:hackathon_proj/mobile/UI/dashbord/ui.dart';
import 'package:hackathon_proj/mobile/UI/submit%20form/func.dart';
import 'package:hackathon_proj/mobile/UI/widgets/online_indicator.dart';
import 'package:hackathon_proj/mobile/api/file_upload.dart';
import 'package:quickalert/quickalert.dart';

class DisasterFormPage extends StatefulWidget {
  const DisasterFormPage({Key? key}) : super(key: key);

  @override
  State<DisasterFormPage> createState() => _DisasterFormPageState();
}

class _DisasterFormPageState extends State<DisasterFormPage> {
  String _incident = '';
  String photo_id = '';
  int _severity = 1;
  String _coords = '';
  String _timestamp = '';
  final TextEditingController _detailsController = TextEditingController();

  void _pickIncident(String id) => setState(() => _incident = id);
  void _setSeverity(int s) => setState(() => _severity = s);

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color darkRed = Color(0xFF8B0000);
    const Color lightRed = Color(0xFFFF6B6B);

    Widget incidentBox({
      required IconData icon,
      required String label,
      required String id,
    }) {
      final selected = _incident == id;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _pickIncident(id),
          child: Ink(
            decoration: BoxDecoration(
              color: selected ? darkRed : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? darkRed : Colors.black12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withOpacity(0.15)
                        : const Color(0xFFF7F7F7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: selected ? Colors.white : darkRed,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF333333),
                    fontWeight: FontWeight.w600,
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
        backgroundColor: darkRed,
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          'Disaster Report',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE6E6), const Color(0xFFF2F2F2)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Incident type container
              OnlineIndicator(asCard: true),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Incident Type',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: incidentBox(
                              icon: Icons.landscape,
                              label: 'Landslide',
                              id: 'LANDSLIDE',
                            ),
                          ),
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: incidentBox(
                              icon: Icons.water,
                              label: 'Flood',
                              id: 'FLOOD',
                            ),
                          ),
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: incidentBox(
                              icon: Icons.block,
                              label: 'Road block',
                              id: 'ROADBLOCK',
                            ),
                          ),
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: incidentBox(
                              icon: Icons.power_off,
                              label: 'Power line down',
                              id: 'POWERDOWN',
                            ),
                          ),
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: incidentBox(
                              icon: Icons.device_unknown,
                              label: 'Other',
                              id: 'OTHER',
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
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Severity',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
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
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? Colors.white
                                          : const Color(0xFF333333),
                                    ),
                                  ),
                                  selected: selected,
                                  onSelected: (_) => _setSeverity(val),
                                  selectedColor: darkRed,
                                  backgroundColor: const Color(0xFFF7F7F7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                '1 = Critical',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                              Text(
                                '5 = Low threat',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const SizedBox(height: 12),

              const SizedBox(height: 12),

              // Photos optional
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Photos (Optional)',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: TextButton.icon(
                            onPressed: () async {
                              photo_id = await Upload_file();
                              setState(() {});
                            },
                            icon: const Icon(Icons.add_a_photo),
                            label: const Text('Add Photos'),
                            style: TextButton.styleFrom(
                              foregroundColor: darkRed,
                            ),
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
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional details',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _detailsController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText:
                              'Enter any extra details about the incident...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F7F7),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                     Submit_request(
                      incident_type: _incident,
                      additional_details: _detailsController.text,
                      severity: _severity,
                      photo_id: photo_id,
                    );
                    await QuickAlert.show(
                      context: context,
                      type: QuickAlertType.success,
                    ).then((_) {
                      GotoPage(context, DashboardPage(), isReplace: true);
                    });

                    // TODO
                  },
                  child: const Text(
                    'Submit Report',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Footer (same as dashboard)
            ],
          ),
        ),
      ),
    );
  }
}
