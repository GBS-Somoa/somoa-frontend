import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:somoa/screens/device/device_qr_scan.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:somoa/services/api_services.dart';
import 'package:somoa/widgets/menu_bar_widget.dart';

class DeviceCreateScreen extends StatefulWidget {
  final String groupId;

  DeviceCreateScreen({super.key, required this.groupId});

  @override
  _DeviceCreateScreenState createState() => _DeviceCreateScreenState();
}

class _DeviceCreateScreenState extends State<DeviceCreateScreen> {
  TextEditingController _deviceCodeController = TextEditingController();
  TextEditingController _nicknameController = TextEditingController();

  var isChanged = false;

  Future<void> _registerDevice() async {
    String deviceCode = _deviceCodeController.text;
    String nickname = _nicknameController.text;

    var bodyData = jsonEncode({
      "groupId": widget.groupId,
      "code": deviceCode,
      "nickname": nickname,
    });

    // .env 파일에서 서버 URL을 가져옵니다.
    String serverUrl = dotenv.get("SERVER_URL");
    String? accessToken = await getAccessToken();
    // print(accessToken);

    // accessToken이 있는 경우에만 요청을 보냅니다.
    if (accessToken != null) {
      Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      http.Response response = await http.post(
        Uri.parse(serverUrl + 'devices'),
        headers: headers,
        body: bodyData,
      );

      if (response.statusCode == 200) {
        setState(() {
          isChanged = true;
        });
        Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));
        Future.microtask(() => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('등록 성공'),
                content: Text(
                  '기기가 등록되었습니다.\nID : ${responseData['data']['deviceId']}\n기기 이름 : $nickname',
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('확인'),
                  ),
                ],
              ),
            ));
        print(responseData);
      } else {
        print(response.body);
        print('Failed to fetch location data: ${response.statusCode}');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('기기 등록에 실패했습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } else {
      print('Access token is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const MenuBarWidget(
          titleText: '기기 추가',
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
                    decoration: InputDecoration(
                      labelText: '기기 코드',
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code),
                          onPressed: () {
                            // TODO: Implement QR code scanning functionality
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const QrScan();
                            }));
                          }),
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
                      onPressed: () async {
                        await _registerDevice();
                        print(isChanged);
                        if (isChanged == true) {
                          Navigator.pop(context, 'isChanged');
                        }
                      },
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
