import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hackathon_proj/main.dart';
import 'package:hackathon_proj/mobile/UI/Profile/Profile.dart';
import 'package:hackathon_proj/mobile/UI/widgets/online_indicator.dart';
import '../submit form/Disaster form.dart';
import '../pending forms/pending forms.dart';
import '../submitted reports/submitted reports.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isOnline = false; // connection status (false = offline)
  String _coords = ''; // placeholder for GPS coordinates
  StreamSubscription<List<ConnectivityResult>>? subscription;
  @override
  initState() {
    super.initState();
    // Initialize connectivity subscription
    subscription = Connectivity().onConnectivityChanged.listen((results) {
      bool online =
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.mobile);
      setState(() {
        _isOnline = online;
      });
    });
  }

  void _toggleConnection() => setState(() => _isOnline = !_isOnline);

  void _showSnack(String label) {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(label)));
    GotoPage(context, ProfilePage());
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
        decoration: const BoxDecoration(color: Color(0xFFE6E6)),
        child: Column(
          children: [
            OnlineIndicator(asCard: true),
            // Top connection status row (repeat for prominence)
            const SizedBox(height: 12),

            // Reverse-pyramid button layout using square gradient buttons
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // make top-left button same size/color as center
                    SizedBox(
                      width: 170,
                      height: 170,
                      child: Material(
                        color: const Color.fromARGB(255, 255, 208, 208),
                        elevation: 10,
                        shadowColor: Colors.black.withOpacity(0.24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DisasterFormPage(),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFFB00020),
                                radius: 30,
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Submit Report',
                                style: TextStyle(
                                  color: Color(0xFFB00020),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // make top-right button same size/color as center
                    SizedBox(
                      width: 170,
                      height: 170,
                      child: Material(
                        color: const Color.fromARGB(118, 184, 184, 184),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PendingFormsPage(),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF757575),
                                radius: 30,
                                child: const Icon(
                                  Icons.pending_actions,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Pending Reports',
                                style: TextStyle(
                                  color: Color(0xFF757575),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                    width: 170,
                    height: 170,
                    child: Material(
                      color: const Color.fromARGB(179, 194, 244, 202),
                      elevation: 10,
                      shadowColor: Colors.black.withOpacity(0.24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SubmittedReportsPage(),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFF2E8B57),
                              radius: 34,
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Submitted Reports',
                              style: TextStyle(
                                color: Color(0xFF2E8B57),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Optional quick action to simulate fetching coordinates
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          Future.delayed(Duration.zero, () async {
print("Getting coordinates...");

                              final pos = await Geolocator.getCurrentPosition(
                            desiredAccuracy: LocationAccuracy.best,
                            timeLimit:Duration(minutes:6 ),
                          );
                          print(  pos);
                          setState(() {
                            // placeholder coordinates (replace with real GPS integration)
                            _coords =
                                '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
                          });
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
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.24),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: largeLabel ? 56 : 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: largeLabel ? 18 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
