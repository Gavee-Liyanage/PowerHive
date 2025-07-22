import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'PaymentSuccessfull.dart';

class CardPaymentPage extends StatefulWidget {
  final String amount;
  final Duration chargingDuration;
  final String chargingType;

  const CardPaymentPage({
    super.key,
    required this.amount,
    required this.chargingDuration,
    required this.chargingType,
  });

  @override
  State<CardPaymentPage> createState() => _CardPaymentPageState();
}

class _CardPaymentPageState extends State<CardPaymentPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  //  Realtime Database Save Function
  Future<void> saveChargingData({
    required String chargingType,
    required String voltage,
    required String price,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final dbRef = FirebaseDatabase.instance.ref();

      // Create new session under user ID
      final newSessionRef =
          dbRef.child('chargingSessions').child(user.uid).push();

      final sessionId = newSessionRef.key;

      await newSessionRef.set({
        'chargingType': chargingType,
        'duration': voltage,
        'price': price,
        'status': 'start',
        'paymentConfirmed': true,
        'timestamp': DateTime.now().toIso8601String(),
      });

      print(" Charging session created: $sessionId");

      await dbRef.child('activeSessions').child('A0:A3:B3:FF:93:D8').set({
        'userId': user.uid,
        'sessionId': sessionId,
      });

      print(" Session pointer updated for ESP32.");
    } catch (e) {
      print(" Failed to save charging session: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Enter Card Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(Icons.credit_card, size: 40, color: Colors.green),
                    const SizedBox(height: 16),
                    const Text(
                      "Secure Card Payment",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: cardNumberController,
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      decoration: const InputDecoration(
                        labelText: "Card Number",
                        prefixIcon: Icon(Icons.credit_card),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.length != 16) {
                          return "Enter a valid 16-digit card number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: cardHolderController,
                      decoration: const InputDecoration(
                        labelText: "Card Holder Name",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Name is required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: expiryController,
                            keyboardType: TextInputType.datetime,
                            decoration: const InputDecoration(
                              labelText: "Expiry Date (MM/YY)",
                              prefixIcon: Icon(Icons.date_range),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  !RegExp(r"^\d{2}/\d{2}$").hasMatch(value)) {
                                return "Invalid expiry";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: cvvController,
                            obscureText: true,
                            maxLength: 3,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "CVV",
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.length != 3) {
                                return "Invalid CVV";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await saveChargingData(
                            chargingType: widget.chargingType,
                            voltage: widget.chargingDuration.toString(),
                            price: widget.amount,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Processing payment of ${widget.amount}..."),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );

                          Future.delayed(const Duration(seconds: 2), () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentSuccessfullPage(
                                  duration: widget.chargingDuration,
                                  isEV: widget.chargingType == "EV",
                                  purchasedKWh: widget.chargingType == "EV"
                                      ? 6.5
                                      : null, // ✅ Example: replace with dynamic value
                                  chargerPower: widget.chargingType == "EV"
                                      ? 7.2
                                      : null, // ✅ Example: replace with dynamic value
                                ),
                              ),
                            );
                          });
                        }
                      },
                      icon: const Icon(Icons.payment),
                      label: Text(
                        "Pay ${widget.amount}",
                        style: const TextStyle(
                            color: Color.fromARGB(255, 250, 251, 252)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
