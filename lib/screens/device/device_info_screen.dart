import 'package:flutter/material.dart';

class DeviceInfoScreen extends StatelessWidget {
  final Map<String, dynamic> deviceInfo;

  const DeviceInfoScreen({super.key, required this.deviceInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('기기 정보'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('기기 코드 : ${deviceInfo['id']}',
                  style: const TextStyle(fontSize: 20)),
              Text('제조사 : ${deviceInfo['manufacturer']}',
                  style: const TextStyle(fontSize: 20)),
              Text('기기 종류 : ${deviceInfo['type']}',
                  style: const TextStyle(fontSize: 20)),
              Text('모델명 : ${deviceInfo['model']}',
                  style: const TextStyle(fontSize: 20)),
              Text('기기 이름 : ${deviceInfo['nickname']}',
                  style: const TextStyle(fontSize: 20)),
              // Add more device information widgets as needed
            ],
          ),
        ),
      ),
    );
  }
}
