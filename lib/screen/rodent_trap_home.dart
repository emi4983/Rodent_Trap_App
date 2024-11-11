import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class RodentTrapHomePage extends StatefulWidget {
  final http.Client? client;

  RodentTrapHomePage({this.client});

  @override
  RodentTrapHomePageState createState() => RodentTrapHomePageState();
}

class RodentTrapHomePageState extends State<RodentTrapHomePage> {
  String _status = "Trap Status: Unknown";
  String raspberryPiUrl = 'http://129.113.130.54:5000';
  Timer? _timer;

  http.Client get client => widget.client ?? http.Client();

  String get status => _status;

  Future<void> startSensor() async {
    try {
      final response = await client.post(
        Uri.parse('$raspberryPiUrl/control'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'start_sensor'}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _status = "Monitoring for rodent...";
          });
        }
        _timer = Timer.periodic(Duration(seconds: 2), (Timer t) => checkTrapStatus());
      } else {
        if (mounted) {
          setState(() {
            _status = "Failed to start sensor.";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = "Error starting sensor: $e";
        });
      }
    }
  }

  Future<void> logTrapEvent(String status) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> logs = prefs.getStringList('trap_logs') ?? [];
    String formattedDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    String formattedTime = DateFormat('hh:mm:ss a').format(DateTime.now());
    logs.add('$formattedDate at $formattedTime: $status');
    await prefs.setStringList('trap_logs', logs);
  }

  Future<void> checkTrapStatus() async {
    try {
      final response = await client.get(
        Uri.parse('$raspberryPiUrl/status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            if (responseData['status'] == 'trapped') {
              _status = "Rodent is trapped!";
              _timer?.cancel();
              logTrapEvent('Rodent trapped');
            } else if (responseData['status'] == 'not_trapped') {
              _status = "No rodent trapped.";
              logTrapEvent('No rodent trapped');
            }
          });
        }
      }
    } catch (e) {
      print("Error checking trap status: $e");
    }
  }

  Future<void> resetTrap() async {
    _timer?.cancel();
    try {
      final response = await client.post(
        Uri.parse('$raspberryPiUrl/control'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'reset_trap'}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _status = "Trap reset successfully.";
          });
        }
        logTrapEvent('Trap reset successfully');
      } else {
        if (mounted) {
          setState(() {
            _status = "Failed to reset the trap.";
          });
        }
        logTrapEvent('Failed to reset trap: Status code ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = "Error resetting trap.";
        });
      }
      logTrapEvent('Error resetting trap: $e');
    }
  }

  Future<List<String>> getTrapLogs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('trap_logs') ?? [];
  }

  Future<void> clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('trap_logs');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rodent Trap Controller', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        _status.contains("trapped") ? Icons.warning_amber_rounded : Icons.info,
                        color: _status.contains("trapped") ? Colors.red : Colors.blue,
                        size: 48,
                      ),
                      SizedBox(height: 10),
                      Text(
                        _status,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    key: Key('startMonitoringButton'),
                    onPressed: startSensor,
                    icon: Icon(Icons.settings_remote, color: Colors.white),
                    label: Text('Start Trap'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green[700],
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    key: Key('resetTrapButton'),
                    onPressed: resetTrap,
                    icon: Icon(Icons.refresh, color: Colors.white),
                    label: Text('Reset Trap'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red[700],
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  List<String> logs = await getTrapLogs();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Trap Logs', style: TextStyle(color: Colors.green[700])),
                        content: Container(
                          width: double.maxFinite,
                          height: 300,
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  itemCount: logs.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      leading: Icon(
                                        logs[index].contains("trapped")
                                            ? Icons.pest_control
                                            : Icons.pest_control_outlined,
                                        color: logs[index].contains("trapped") ? Colors.red : Colors.blue,
                                      ),
                                      title: Text(
                                        logs[index],
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  bool confirm = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Clear All Logs"),
                                        content: Text("Are you sure you want to delete all logs?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: Text("Confirm"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (confirm == true) {
                                    await clearLogs();
                                    setState(() {});
                                    Navigator.pop(context);
                                  }
                                },
                                icon: Icon(Icons.delete_forever),
                                label: Text("Clear All Logs"),
                                style: ElevatedButton.styleFrom(primary: Colors.red[700]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Text('View Logs', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(primary: Colors.blue[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

