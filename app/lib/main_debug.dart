import 'package:flutter/material.dart';

void main() {
  print('🚀 Safe Mode App Starting... 🚀');
  runApp(const SafeModeApp());
}

class SafeModeApp extends StatelessWidget {
  const SafeModeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 100, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Safe Mode Launch Success!',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Bundle ID: com.cclab.withBible.app',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
