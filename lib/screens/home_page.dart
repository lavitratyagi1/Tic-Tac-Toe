import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'settings_screen.dart';
import 'game_screen.dart';
import 'Game_screen_PvC.dart'; // Import the new PvC game screen

class HomePage extends StatelessWidget {
  void _handleButtonClick(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;

    if (vibrationEnabled) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 50);
      }
    }

    // Your button click handling code here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe'),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome to Tic Tac Toe!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              _buildMenuButton(context, 'Play PvP', Icons.play_arrow, () {
                _handleButtonClick(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GamePage()),
                );
              }),
              SizedBox(height: 20),
              _buildMenuButton(context, 'Play PvC', Icons.computer, () { // New button for PvC mode
                _handleButtonClick(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GamePagePVC()),
                );
              }),
              SizedBox(height: 20),
              _buildMenuButton(context, 'Settings', Icons.settings, () {
                _handleButtonClick(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              }),
              SizedBox(height: 20),
              _buildMenuButton(context, 'Exit', Icons.exit_to_app, () {
                _handleButtonClick(context);
                SystemNavigator.pop();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        primary: Colors.grey[800],
        onPrimary: Colors.white,
        shadowColor: Colors.blueAccent,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        textStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      icon: Icon(icon, size: 30),
      label: Text(text),
      onPressed: onPressed,
    );
  }
}
