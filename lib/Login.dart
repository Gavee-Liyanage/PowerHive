import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'SignUp.dart';
import 'HomePage.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Your integrated login function
  Future<void> loginUser(BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Get ID Token (JWT)
      String idToken = (await userCredential.user!.getIdToken())!;

      print("User signed in. ID Token:");
      print(idToken);

      // Send this token to ESP32 via Bluetooth or Wi-Fi
      sendTokenToESP32(idToken);

      // Log user activity in Realtime Database
      DatabaseReference userRef = FirebaseDatabase.instance.ref("users/${userCredential.user!.uid}");
      await userRef.update({
        'email': email,
        'lastLogin': DateTime.now().toIso8601String(),
      });

      // Create session for ESP32 to read
      String deviceId = "A0:A3:B3:FF:93:D8";
      String sessionId = FirebaseDatabase.instance.ref().push().key ?? "session_${DateTime.now().millisecondsSinceEpoch}";

      DatabaseReference sessionRef = FirebaseDatabase.instance.ref("activeSessions/$deviceId");
      await sessionRef.set({
        'userId': userCredential.user!.uid,
        'sessionId': sessionId,
      });

      // Navigate to ChargingOptionsScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChargingOptionsScreen()),
      );
    } catch (e) {
      print("Login failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.toString()}")),
      );
    }
  }

  // Placeholder for sending token to ESP32 — you can implement Bluetooth or HTTP request to send token to ESP32
  void sendTokenToESP32(String token) {
    // TODO: Implement Bluetooth or HTTP request to send token to ESP32
    print("Sending token to ESP32: $token");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 254, 255, 254),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.electric_car, size: 72, color: Colors.green[700]),
              SizedBox(height: 20),
              Text(
                'Welcome to PowerHive',
                style: TextStyle(
                  color: const Color.fromARGB(255, 27, 72, 29),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 44, 121, 48)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.shade700, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 42, 114, 46)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.shade700, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();

                  if (email.isNotEmpty && password.isNotEmpty) {
                    await loginUser(context, email, password);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter email and password")),
                    );
                  }
                },
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
                child: Text(
                  'Don\'t have an account? Sign Up',
                  style: TextStyle(
                    color: Color.fromARGB(255, 51, 137, 55),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
