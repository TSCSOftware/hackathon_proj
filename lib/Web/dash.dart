import 'package:flutter/material.dart';

class WebDashPage extends StatelessWidget {
  const WebDashPage({Key? key}) : super(key: key);

  void _onTap(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label tapped')));
  }

  Widget _buildButton(BuildContext context, {required IconData icon, required String label, required Color color}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onTap(context, label),
        child: Container(
          width: 220,
          height: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color,
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Web Dashboard')),
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: isWide
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButton(context, icon: Icons.map, label: 'Live Map', color: Colors.teal),
                      const SizedBox(width: 24),
                      _buildButton(context, icon: Icons.report, label: 'Reports', color: Colors.deepOrange),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildButton(context, icon: Icons.map, label: 'Live Map', color: Colors.teal),
                      const SizedBox(height: 16),
                      _buildButton(context, icon: Icons.report, label: 'Reports', color: Colors.deepOrange),
                    ],
                  ),
          ),
        );
      }),
    );
  }
}
