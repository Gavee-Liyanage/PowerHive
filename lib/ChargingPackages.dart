import 'package:flutter/material.dart';
import 'ProceedToPayment.dart';

class ChargingPackagesPage extends StatefulWidget {
  final String chargingType;
  final int selectedPort;

  ChargingPackagesPage({super.key, required this.chargingType,required this.selectedPort,});

  @override
  State<ChargingPackagesPage> createState() => _ChargingPackagesPageState();
}

class _ChargingPackagesPageState extends State<ChargingPackagesPage> {
  final List<Map<String, String>> packages = [
    {"voltage": "30 minutes", "price": "Rs. 500"},
    {"voltage": "1 hour", "price": "Rs. 1000"},
    {"voltage": "1 hour 30 minutes", "price": "Rs. 1500"},
    {"voltage": "2 hours", "price": "Rs. 2000"},
    {"voltage": "3 hours", "price": "Rs. 3000"},
    {"voltage": "4 hours", "price": "Rs. 4000"},
  ];

  int? hoveredIndex;
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Package Selection",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 60, 114, 62),
      ),
      backgroundColor: const Color.fromARGB(255, 254, 255, 254),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: packages.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final package = packages[index];
            final isHovered = hoveredIndex == index;

            return MouseRegion(
              onEnter: (_) => setState(() => hoveredIndex = index),
              onExit: (_) => setState(() => hoveredIndex = null),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 200),
                tween: Tween<double>(begin: 1.0, end: isHovered ? 1.03 : 1.0),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: GestureDetector(
                      onTapDown: (_) {
                        setState(() => selectedIndex = index);
                      },
                      onTapUp: (_) {
                        setState(() => selectedIndex = null);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Selected ${package['voltage']}"),
                            backgroundColor: Colors.green[700],
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 193, 223, 194),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.battery_charging_full,
                                size: 36, color: Colors.green),
                            const SizedBox(height: 10),
                            Text("${package['voltage']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                )),
                            Text("${package['price']}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                )),
                            const SizedBox(height: 10),
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 1.0,
                                end: selectedIndex == index ? 0.95 : 1.0,
                              ),
                              duration: const Duration(milliseconds: 100),
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "You selected ${package['voltage']}"),
                                          backgroundColor: Colors.green[700],
                                        ),
                                      );

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PaymentPage(
                                            chargingType: widget.chargingType,
                                            voltage: package['voltage']!,
                                            price: package['price']!,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[700],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                    ),
                                    child: const Text("Select",
                                        style:
                                            TextStyle(color: Colors.white)),
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
