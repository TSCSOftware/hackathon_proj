import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isOnline = false; // connection status (false = offline)
  String _coords = ''; // placeholder for GPS coordinates

  void _toggleConnection() => setState(() => _isOnline = !_isOnline);

  void _showSnack(String label) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(label)));
  }

  @override
  Widget build(BuildContext context) {
    const Color darkRed = Color(0xFF6B0000);
    const Color lightRed = Color(0xFFE53935);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: darkRed,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => _showSnack('Profile tapped'),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: darkRed),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: const Color(0xFFFFF3CD)
        ),
        child: Column(
          children: [
            // Top connection status row (repeat for prominence)
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _isOnline ? Colors.green : Colors.red,
                  radius: 10,
                ),
                title: Text(
                  _isOnline ? 'Connected to network' : 'Offline',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: TextButton(
                  onPressed: _toggleConnection,
                  child: Text(_isOnline ? 'Go Offline' : 'Try Connect'),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Reverse-pyramid button layout using square gradient buttons
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // make top-left button same size/color as center
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: InkWell(
                        onTap: () => _showSnack('Submit Report'),
                        child: Container(
                          color: const Color.fromARGB(255, 255, 25, 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.send, color: Colors.white, size: 48),
                              SizedBox(height: 8),
                              Text('Submit Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // make top-right button same size/color as center
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: InkWell(
                        onTap: () => _showSnack('Pending Reports'),
                        child: Container(
                          color: Colors.grey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.pending_actions, color: Colors.white, size: 48),
                              SizedBox(height: 8),
                              Text('Pending Reports', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: InkWell(
                      onTap: () => _showSnack('Submitted Reports'),
                      child: Container(
                        color: const Color.fromARGB(255, 13, 181, 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check, color: Colors.white, size: 56),
                            SizedBox(height: 8),
                            Text('Submitted Reports', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Blank container for GPS coordinates
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your current co-ordinates',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _coords.isEmpty ? '-' : _coords,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    // Optional quick action to simulate fetching coordinates
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            // placeholder coordinates (replace with real GPS integration)
                            _coords = '6.9271° N, 79.8612° E';
                          });
                        },
                        child: const Text('Get Coordinates'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Disaster Mangement of Sri Lanka',
                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.9), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable square gradient button with centered icon and label
class _GradientSquareButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final List<Color> colors;
  final bool largeLabel;

  const _GradientSquareButton({
    Key? key,
    required this.onTap,
    required this.icon,
    required this.label,
    required this.colors,
    this.largeLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 6, offset: const Offset(0, 4))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: largeLabel ? 56 : 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: Colors.white, fontSize: largeLabel ? 18 : 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
