import 'package:flutter/material.dart';
import 'package:hackathon_proj/Web/live_data.dart';
import 'package:hackathon_proj/Web/web%20dashboard.dart';
import 'package:hackathon_proj/main.dart';
import 'package:hackathon_proj/mobile/UI/widgets/on_tap_db_button.dart';

class WebDashPage extends StatelessWidget {
  const WebDashPage({Key? key}) : super(key: key);

  // Replaced with reusable OnTapDBButton widget (see lib/mobile/UI/widgets/on_tap_db_button.dart)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B0000),
        centerTitle: true,
        title: const Text(
          'Web Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: isWide
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OnTapDBButton(
                          icon: Icons.map,
                          label: 'Live Map',
                          color: Colors.teal,
                          onTap: () {
                            GotoPage(context, WebDashboardPage());
                          },
                        ),
                        const SizedBox(width: 24),
                        OnTapDBButton(
                          icon: Icons.report,
                          label: 'Reports',
                          color: Colors.deepOrange,
                          onTap: () {
                            GotoPage(context, LiveDataPage());
                          },
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OnTapDBButton(
                          icon: Icons.map,
                          label: 'Live Map',
                          color: Colors.teal,
                          onTap: () {
                            GotoPage(context, WebDashboardPage());
                          },
                        ),
                        const SizedBox(height: 16),
                        OnTapDBButton(
                          icon: Icons.report,
                          label: 'Reports',
                          color: Colors.deepOrange,
                          onTap: () {
                            GotoPage(context, LiveDataPage());
                          },
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}
