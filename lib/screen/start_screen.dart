import 'package:flutter/material.dart';
import 'rodent_trap_home.dart'; // Import the home screen for navigation

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content of the start screen
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to Rodent Trap System',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the RodentTrapHomePage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RodentTrapHomePage()),
                    );
                  },
                  child: Text('Get Started'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green[600],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Positioned image in the bottom-right corner, with increased size
          Positioned(
            bottom: 10, // Distance from the bottom of the screen
            right: 10,  // Distance from the right of the screen
            child: Container(
              // Adjust image size directly with fixed values
              width: 200, // Increased width to 200
              height: 200, // Increased height to 200
              decoration: BoxDecoration(
                color: Colors.transparent, // No background color
              ),
              child: Image.asset(
                'assets/images/your_image.png', // Ensure this PNG has transparency
                fit: BoxFit.contain, // Ensures the image fits inside without stretching
              ),
            ),
          ),

          // Alternatively, use MediaQuery to make the image responsive to screen size
          /*
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.2, // 20% of screen width
              height: MediaQuery.of(context).size.height * 0.2, // 20% of screen height
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: Image.asset(
                'assets/images/your_image.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          */
        ],
      ),
    );
  }
}
