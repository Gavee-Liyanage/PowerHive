import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ChargingHistoryPage extends StatelessWidget {
  const ChargingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Charging History")),
        body: const Center(child: Text("User not logged in.")),
      );
    }

    final DatabaseReference historyRef = FirebaseDatabase.instance
        .ref()
        .child('chargingSessions')
        .child(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Charging History", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[800],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: historyRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load history."));
          }

          final rawData = snapshot.data?.snapshot.value;

          if (rawData == null) {
            return const Center(child: Text("No charging history found."));
          }

          Map<dynamic, dynamic> data;
          try {
            data = Map<dynamic, dynamic>.from(rawData as Map);
          } catch (e) {
            print(" Data parsing error: $e");
            return const Center(child: Text("Data format error."));
          }

          final historyList = data.entries.map((e) {
            final session = Map<String, dynamic>.from(e.value);
            session['id'] = e.key;
            return session;
          }).toList();

          historyList.sort((a, b) {
            final dateA = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime(2000);
            final dateB = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime(2000);
            return dateB.compareTo(dateA);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final session = historyList[index];
              final chargingType = session['chargingType'] ?? 'Unknown';
              final duration = session['duration'] ?? '-';
              final price = session['price'] ?? '-';
              final timestamp = session['timestamp'];

              DateTime? date;
              if (timestamp != null && timestamp is String) {
                date = DateTime.tryParse(timestamp);
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  leading: Icon(
                    chargingType == 'EV' ? Icons.electric_car : Icons.bolt,
                    color: Colors.teal,
                    size: 32,
                  ),
                  title: Text(
                    "$chargingType Charging",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Duration: $duration"),
                      Text("Price: LKR $price"),
                      if (date != null)
                        Text("Date: ${date.toLocal()}".split('.').first),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
