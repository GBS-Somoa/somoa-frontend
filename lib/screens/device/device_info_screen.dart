import 'package:flutter/material.dart';

class DeviceInfoScreen extends StatelessWidget {
  final Map<String, dynamic> deviceInfo;

  const DeviceInfoScreen({super.key, required this.deviceInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Info'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Device Name: ${deviceInfo['name']}'),
            Text('Device Model: ${deviceInfo['model']}'),
            Text('Device OS: ${deviceInfo['os']}'),
            // Add more device information widgets as needed
          ],
        ),
      ),
    );
  }
}
