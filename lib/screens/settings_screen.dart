import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load settings from SharedPreferences
  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
    });
  }

  // Save settings to SharedPreferences
  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('soundEnabled', _soundEnabled);
    prefs.setBool('vibrationEnabled', _vibrationEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildSwitchListTile(
              'Enable Sound',
              _soundEnabled,
              (value) {
                setState(() {
                  _soundEnabled = value;
                  if (_vibrationEnabled) {
                    Vibration.vibrate(duration: 50);
                  }
                  _saveSettings();
                });
              },
            ),
            SizedBox(height: 20),
            _buildSwitchListTile(
              'Enable Vibration',
              _vibrationEnabled,
              (value) {
                setState(() {
                  _vibrationEnabled = value;
                  if (_vibrationEnabled) {
                    Vibration.vibrate(duration: 50);
                  }
                  _saveSettings();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchListTile(
      String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue,
      activeTrackColor: Colors.blueAccent,
      inactiveThumbColor: Colors.grey[800],
      inactiveTrackColor: Colors.grey[600],
    );
  }
}
