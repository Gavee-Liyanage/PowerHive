import 'dart:async';
import 'package:flutter/material.dart';
import 'CountdownPage.dart';
import 'Countdown_kWh.dart'; // ✅ Import the EV countdown page

class PaymentSuccessfullPage extends StatefulWidget {
  final Duration duration;        // For Mobile Charging
  final bool isEV;                // ✅ New parameter to know if EV or Mobile
  final double? purchasedKWh;     // ✅ For EV Charging (optional)
  final double? chargerPower;     // ✅ EV Charger power (optional)

  const PaymentSuccessfullPage({
    Key? key,
    required this.duration,
    required this.isEV,
    this.purchasedKWh,
    this.chargerPower,
  }) : super(key: key);

  @override
  State<PaymentSuccessfullPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessfullPage> {
  @override
  void initState() {
    super.initState();

    // Redirect after 4 seconds
    Timer(const Duration(seconds: 4), () {
      if (widget.isEV) {
        // ✅ Redirect to kWh countdown for EV
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => CountdownKWhPage(
              initialKWh: widget.purchasedKWh ?? 5.0, // default if null
              chargerPower: widget.chargerPower ?? 7.2, // default if null
            ),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        // ✅ Redirect to time countdown for Mobile
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => CountdownPage(initialTime: widget.duration),
          ),
          (Route<dynamic> route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Payment Successful"),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
              SizedBox(height: 24),
              Text(
                "Thank you!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                "Your payment was processed successfully.",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(color: Colors.green),
              SizedBox(height: 12),
              Text("Redirecting to Home...", style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
