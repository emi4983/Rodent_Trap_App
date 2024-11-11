import 'package:flutter/material.dart';
import 'package:rodent_trap_app/screen/start_screen.dart'; // Import the start screen

void main() {
  runApp(RodentTrapApp());
}

class RodentTrapApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rodent Trap App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Arial',
      ),
      home: StartScreen(), // Set StartScreen as the initial screen
    );
  }
}



