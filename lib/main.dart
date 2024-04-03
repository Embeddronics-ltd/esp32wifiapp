// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
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
    if (_ssid.isEmpty) {
      // Check if SSID or password is empty
      print("SSID cannot be empty");
      return;
    }

    if (await _checkPermissions()) {
      try {
      //  await WiFiForIoTPlugin.removeWifiNetwork(_ssid);
        await WiFiForIoTPlugin.connect(_ssid,
            password: _password,security: NetworkSecurity.WPA, withInternet: false, joinOnce: true,timeoutInSeconds: 60);
        print("Connected to $_ssid");
      } catch (e) {
        print("Error connecting: $e");
      }
    } else {
      print("Don't have permission");
    }
  }

  void _sendSSIDAndPassword() async {
    WiFiForIoTPlugin.forceWifiUsage(true);
    // var response = await http.post(
    //   Uri.parse('http://192.168.4.1/wifisave?s=$_ssid&p=$_password'),
    //   headers: {'Content-Type': 'application/json'},
    // );
    final dio = Dio();
        var response = await dio.post('http://192.168.4.1/wifisave?s=$_ssid&p=$_password');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("SSID and password sent successfully"),
        ),
      );
    } else {
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
            decoration: const InputDecoration(labelText: 'SSID'),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) {
              setState(() {
                _password = value; // Update password variable as user types
              });
            },
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
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
