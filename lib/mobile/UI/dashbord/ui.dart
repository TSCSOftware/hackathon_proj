import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  void _onTap(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Tapped $label')));
  }

  @override
  Widget build(BuildContext context) {
    const Color darkRed = Color(0xFF6B0000);
    const Color lightRed = Color(0xFFE53935);

    final items = [
      {'label': 'Emergency', 'icon': Icons.warning, 'color': lightRed},
      {'label': 'Map', 'icon': Icons.map, 'color': darkRed},
      {'label': 'Messages', 'icon': Icons.message, 'color': lightRed},
      {'label': 'Profile', 'icon': Icons.person, 'color': darkRed},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), backgroundColor: darkRed),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [lightRed, darkRed],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: items.map((it) {
            return GestureDetector(
              onTap: () => _onTap(context, it['label'] as String),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: it['color'] as Color,
                      child: Icon(
                        it['icon'] as IconData,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      it['label'] as String,
                      style: const TextStyle(
                        color: darkRed,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
