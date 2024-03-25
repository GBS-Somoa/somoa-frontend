import 'package:flutter/material.dart';

class DeviceCreateScreen extends StatefulWidget {
  @override
  _DeviceCreateScreenState createState() => _DeviceCreateScreenState();
}

class _DeviceCreateScreenState extends State<DeviceCreateScreen> {
  TextEditingController _serialNumberController = TextEditingController();
  TextEditingController _nicknameController = TextEditingController();

  void _registerDevice() {
    String serialNumber = _serialNumberController.text;
    String nickname = _nicknameController.text;

    // TODO: Send device registration request to the server

    // Example code to print the entered values
    print('Serial Number: $serialNumber');
    print('Nickname: $nickname');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _serialNumberController,
              decoration: const InputDecoration(
                labelText: 'Serial Number',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: 'Nickname',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _registerDevice,
              child: const Text('Register Device'),
            ),
          ],
        ),
      ),
    );
  }
}
