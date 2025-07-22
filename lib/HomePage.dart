import 'package:flutter/material.dart';
import 'History.dart';
import 'PortSelection.dart';


class ChargingOptionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Text(
              'Power Hive',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 27, 72, 29),
                letterSpacing: 2.0,
              ),
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChargingCard(
                title: 'EV Charging',
                icon: Icons.electric_car,
                onTap: () async {
                  List<bool> evPortStatus = await getEVPortStatusFromESP32();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PortSelectionPage(
                        chargingType: 'EV',
                        portAvailability: evPortStatus,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              ChargingCard(
                title: 'Mobile Charging',
                icon: Icons.phone_android,
                onTap: () async {
                  List<bool> mobilePorts = await getMobilePortsStatusFromESP32();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PortSelectionPage(
                        chargingType: 'Mobile',
                        portAvailability: mobilePorts,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              ChargingCard(
                title: 'Charging History',
                icon: Icons.history,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChargingHistoryPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChargingCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  ChargingCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  State<ChargingCard> createState() => _ChargingCardState();
}

class _ChargingCardState extends State<ChargingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1.0, end: _isHovered ? 1.03 : 1.0),
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 205, 237, 206),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(widget.icon, size: 60, color: Colors.green[800]),
                      SizedBox(height: 10),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// 🔧 Mock ESP32 response — Replace with your real logic later
Future<List<bool>> getEVPortStatusFromESP32() async {
  await Future.delayed(Duration(milliseconds: 300));
  return [true];
}

Future<List<bool>> getMobilePortsStatusFromESP32() async {
  await Future.delayed(Duration(milliseconds: 300));
  return [true, false];
}
