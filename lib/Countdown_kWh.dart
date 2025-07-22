import 'dart:async';
import 'package:flutter/material.dart';
import 'HomePage.dart';

class CountdownKWhPage extends StatefulWidget {
  final double initialKWh; 
  final double chargerPower; 

  const CountdownKWhPage({
    Key? key,
    required this.initialKWh,
    required this.chargerPower,
  }) : super(key: key);

  @override
  _CountdownPageState createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownKWhPage> {
  late double kWhLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    kWhLeft = widget.initialKWh;
    startCountdown();
  }

  void startCountdown() {
    
    final kWhPerSecond = widget.chargerPower / 3600;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (kWhLeft > 0) {
        setState(() {
          kWhLeft = (kWhLeft - kWhPerSecond).clamp(0, widget.initialKWh);
        });
      } else {
        timer.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Charging complete! Thank you for choosing our service."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = Colors.green[800]!;
    final double progress = widget.initialKWh == 0
        ? 0
        : kWhLeft / widget.initialKWh;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Charging Status", style: TextStyle(color: Colors.white)),
        backgroundColor: themeColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              '⚡ PowerHive',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: themeColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt, size: 56, color: Colors.green),
                      const SizedBox(height: 16),
                      const Text("Energy Remaining", style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(
                        "${kWhLeft.toStringAsFixed(2)} kWh",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      LinearProgressIndicator(
                        value: progress,
                        color: themeColor,
                        backgroundColor: Colors.green[100],
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => ChargingOptionsScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.home),
              label: const Text("Return to Home"),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
