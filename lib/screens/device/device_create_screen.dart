import 'package:flutter/material.dart';

class DeviceCreateScreen extends StatefulWidget {
  @override
  _DeviceCreateScreenState createState() => _DeviceCreateScreenState();
}

class _DeviceCreateScreenState extends State<DeviceCreateScreen> {
  TextEditingController _deviceCodeController = TextEditingController();
  TextEditingController _nicknameController = TextEditingController();

  void _registerDevice() {
    String deviceCode = _deviceCodeController.text;
    String nickname = _nicknameController.text;

    // TODO: Send device registration request to the server

    // Example code to print the entered values
    print('Serial Number: $deviceCode');
    print('Nickname: $nickname');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('기기 추가'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _deviceCodeController,
                    decoration: const InputDecoration(
                      labelText: '기기 코드',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35.0),
                  TextField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(
                      labelText: '기기 이름',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  FractionallySizedBox(
                    widthFactor: 0.8, // Set width to 70% of the screen width
                    child: ElevatedButton(
                      onPressed: _registerDevice,
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          '등록',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
