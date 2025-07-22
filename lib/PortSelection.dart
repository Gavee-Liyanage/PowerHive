import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'ChargingPackages.dart';
import 'ChargingPackagesEV.dart';

class PortSelectionPage extends StatefulWidget {
  final String chargingType;
  final List<bool> portAvailability;

  PortSelectionPage({
    required this.chargingType,
      required this.portAvailability,
  });

  @override
  _PortSelectionPageState createState() => _PortSelectionPageState();
}

class _PortSelectionPageState extends State<PortSelectionPage> {
  final DatabaseReference portsRef = FirebaseDatabase.instance.ref('ports');
  List<bool> portAvailability = [false, false]; 

  @override
  void initState() {
    super.initState();
    if (widget.chargingType == "Mobile") {
      
      portsRef.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value as Map?;
        if (data != null) {
          setState(() {
            portAvailability = [
              data['port1'] == 'available',
              data['port2'] == 'available',
            ];
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    List<bool> portsToShow;
    String sectionTitle;
    int startIndex;

    if (widget.chargingType == 'Mobile') {
      portsToShow = portAvailability;
      sectionTitle = 'Mobile Charging Ports';
      startIndex = 0;
    } else {
      
      portsToShow = [true]; 
      sectionTitle = 'EV Charging Ports';
      startIndex = 0;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Available Ports'),
        backgroundColor: Colors.green[800],
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(height: 24),
            Text(
              'Select an available port to continue:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.teal[900],
              ),
            ),
            SizedBox(height: 24),
            sectionHeader(sectionTitle),
            buildPortList(context, screenWidth, portsToShow, startIndex),
          ],
        ),
      ),
    );
  }

  Widget sectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green[900],
        ),
      ),
    );
  }

  Widget buildPortList(BuildContext context, double screenWidth, List<bool> ports, int startIndex) {
    return Column(
      children: List.generate(ports.length, (index) {
        final isAvailable = ports[index];
        final portNumber = startIndex + index + 1;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Center(
            child: GestureDetector(
              onTap: isAvailable
    ? () {
        if (widget.chargingType == 'Mobile') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChargingPackagesPage(
                chargingType: widget.chargingType,
                selectedPort: portNumber,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChargingPackagesEVPage(
                chargingType: widget.chargingType,
                selectedPort: portNumber,
              ),
            ),
          );
        }
      }
    : null,

              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: screenWidth * 0.9,
                height: 110,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  gradient: isAvailable
                      ? LinearGradient(
                          colors: [Colors.green.shade300, Colors.green.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      isAvailable ? Icons.check_circle : Icons.cancel,
                      color: Colors.white,
                      size: 38,
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Port $portNumber',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isAvailable ? 'Available' : 'Unavailable',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
