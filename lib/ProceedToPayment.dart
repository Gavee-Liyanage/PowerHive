import 'package:flutter/material.dart';
import 'Payment.dart';

class PaymentPage extends StatelessWidget {
  final String voltage;
  final String price;
  final String chargingType;

  const PaymentPage({
    super.key,
    required this.voltage,
    required this.price,
    required this.chargingType,
  });


  Duration parseDuration(String timeString) {
    if (timeString.contains("hour")) {
      final parts = timeString.split(" ");
      int hours = 0;
      int minutes = 0;

      for (int i = 0; i < parts.length; i++) {
        if (parts[i] == "hour" || parts[i] == "hours") {
          hours = int.parse(parts[i - 1]);
        }
        if (parts[i] == "minutes") {
          minutes = int.parse(parts[i - 1]);
        }
      }

      return Duration(hours: hours, minutes: minutes);
    } else if (timeString.contains("minutes")) {
      int minutes = int.parse(timeString.split(" ")[0]);
      return Duration(minutes: minutes);
    }

    return Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    IconData chargingIcon =
        chargingType == "EV" ? Icons.electric_car : Icons.phone_android;
    Color themeColor =
        chargingType == "EV" ? Colors.green[800]! : Colors.green[800]!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Confirm Payment",style: TextStyle(color: Colors.white),),
        backgroundColor: themeColor,
        leading: const BackButton(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: themeColor.withOpacity(0.1),
                    child: Icon(chargingIcon, size: 40, color: themeColor),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "${chargingType == "EV" ? "EV" : "Mobile"} Charging",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(thickness: 1.2, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Duration", style: TextStyle(fontSize: 16)),
                      Text(voltage,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Price", style: TextStyle(fontSize: 16)),
                      Text(price,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // 🔽 Pass charging duration to CardPaymentPage
                        Duration duration = parseDuration(voltage);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text("Redirecting to payment gateway..."),
                            backgroundColor: themeColor,
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CardPaymentPage(
                              amount: price,
                              chargingDuration: duration,
                              chargingType: chargingType, // 👈 add this line
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "Proceed to Payment",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
