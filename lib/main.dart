import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_iot_wifi/flutter_iot_wifi.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Esp32 Wifi App'),
        ),
        body: const Center(
          child: AccessPointWidget(),
        ),
      ),
    );
  }
}

class AccessPointWidget extends StatefulWidget {
  const AccessPointWidget({Key? key}) : super(key: key);

  @override
  _AccessPointWidgetState createState() => _AccessPointWidgetState();
}

class _AccessPointWidgetState extends State<AccessPointWidget> {
  String _ssid = ""; // Variable to store SSID entered by the user
  String _password = ""; // Variable to store password entered by the user

  Future<bool> _checkPermissions() async {
    if (Platform.isIOS || await Permission.location.request().isGranted) {
      return true;
    }
    return false;
  }

  void _connect() async {
    if (_ssid.isEmpty || _password.isEmpty) {
      // Check if SSID or password is empty
      print("SSID or password cannot be empty");
      return;
    }

    if (await _checkPermissions()) {
      FlutterIotWifi.connect(_ssid, _password, prefix: true).then((value) => print("connect initiated: $value"));
    } else {
      print("Don't have permission");
    }
  }

  void _sendSSIDAndPassword() async {
    // Create a map of the form fields and their values
    // Map<String, String> formData = {
    //   's': _ssid, // Replace 'your_ssid' with the actual SSID
    //   'p': _password, // Replace 'your_password' with the actual password
    // };

    // // Encode the form data as a JSON string
    // String jsonFormData = jsonEncode(formData);

    // Send the HTTP POST request
    var response = await http.post(
      Uri.parse('http://192.168.4.1/wifisave?s=$_ssid&p=$_password'),
      // body: jsonFormData,
      headers: {'Content-Type': 'application/json'},
    );

  // Check the response status code
  if (response.statusCode == 200) {
    // Show a confirmation message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("SSID and password sent successfully"),
      ),
    );
  } else {
    // Show an error message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Error sending SSID and password"),
      ),
    );
  }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _ssid = value; // Update SSID variable as user types
              });
            },
            decoration: InputDecoration(labelText: 'SSID'),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) {
              setState(() {
                _password = value; // Update password variable as user types
              });
            },
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _connect,
            child: const Text("Connect"),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _sendSSIDAndPassword,
            child: const Text("Send SSID and Password"),
          ),
        ],
      ),
    );
  }
}