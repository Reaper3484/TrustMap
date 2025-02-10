import 'package:flutter/material.dart';
import 'package:safety_application/google_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GoogleMapFlutter(), // Directly showing the map
    );
  }
}
