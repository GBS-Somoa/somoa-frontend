import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:somoa/models/device_model.dart';
import 'package:somoa/screens/device/device_create_screen.dart';
import 'package:somoa/services/api_services.dart';
import 'package:somoa/widgets/device_widget.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  List<dynamic> locationList = [];
  late int _selectedLocation;
  List<Device> deviceList = [];

  bool isLoading = true;

  void refreshDevices() {
    fetchDeviceData(_selectedLocation.toString());
  }

  @override
  void initState() {
    super.initState();
    locationList = [];
    _selectedLocation = 0;
    fetchLocationData();
  }

  // 사용자가 포함된 그룹 리스트 가져오는 코드
  Future<void> fetchLocationData() async {
    setState(() {
      isLoading = true;
    });
    String serverUrl = dotenv.get("SERVER_URL");
    String? accessToken = await getAccessToken();

    if (accessToken != null) {
      Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      http.Response response = await http.get(
        Uri.parse(serverUrl + 'groups'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          locationList = responseData['data'];
          _selectedLocation = locationList[0]['groupId'];
          fetchDeviceData(_selectedLocation.toString());
        });
      } else {
        print(response.body);
        print('Failed to fetch location data: ${response.statusCode}');
      }
    } else {
      print('Access token is null');
    }
  }

  void _registerLocation(String groupName) async {
    var bodyData = jsonEncode({
      "groupName": groupName,
    });

    String serverUrl = dotenv.get("SERVER_URL");
    String? accessToken = await getAccessToken();

    if (accessToken != null) {
      Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      http.Response response = await http.post(
        Uri.parse(serverUrl + 'groups'),
        headers: headers,
        body: bodyData,
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('$groupName 장소가 추가 되었습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  fetchLocationData();
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      } else {
        print(response.body);
        print('Failed to fetch location data: ${response.statusCode}');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('장소 추가에 실패했습니다.'),
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

  Future<void> fetchDeviceData(String groupId) async {
    setState(() {
      isLoading = true;
    });
    String serverUrl = dotenv.get("SERVER_URL");
    String? accessToken = await getAccessToken();
    String url = '${serverUrl}groups/$groupId/devices';

    if (accessToken != null) {
      Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      http.Response response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));

        List<dynamic> tmpDeviceList = responseData['data'];
        List<Device> devices = tmpDeviceList
            .map((deviceJson) => Device.fromJson(deviceJson))
            .toList();

        for (var device in devices) {
          device.supplies.sort((a, b) => a.id.compareTo(b.id));
        }

        setState(() {
          deviceList = devices;
          isLoading = false;
        });
      } else {
        print(response.body);
        print('Failed to fetch location data: ${response.statusCode}');
      }
    } else {
      print('Access token is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: isLoading
            ? const Text('', style: TextStyle(fontSize: 28))
            : Column(
                children: [
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.home),
                          SizedBox(
                            width: 150.0,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: _selectedLocation,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedLocation = newValue!;
                                    fetchDeviceData(
                                        _selectedLocation.toString());
                                  });
                                },
                                items: locationList
                                    .map<DropdownMenuItem<int>>((value) {
                                  return DropdownMenuItem<int>(
                                    value: value['groupId'],
                                    child: Text(value['groupName']),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          showMenu(
                            context: context,
                            position: const RelativeRect.fromLTRB(90, 70, 0, 0),
                            items: [
                              PopupMenuItem(
                                value: '장소 추가',
                                child: const Text('장소 추가'),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      String placeName = '';

                                      return AlertDialog(
                                        title: const Text(
                                          '장소 추가',
                                          textAlign: TextAlign.center,
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              onChanged: (value) {
                                                placeName = value;
                                              },
                                              decoration: const InputDecoration(
                                                  hintText: "장소 이름을 입력하세요",
                                                  border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color:
                                                              Colors.black))),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () {
                                              if (placeName.isNotEmpty) {
                                                _registerLocation(placeName);
                                                Navigator.of(context).pop();
                                              }
                                            },
                                            child: const Text(
                                              '확인',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              PopupMenuItem(
                                value: '장소 관리',
                                child: const Text('장소 관리'),
                                onTap: () {
                                  Navigator.pushNamed(
                                          context, '/locationSetting',
                                          arguments: _selectedLocation)
                                      .then((_) {
                                    fetchLocationData();
                                  });
                                },
                              ),
                              PopupMenuItem(
                                value: '기기 추가',
                                child: const Text('기기 추가'),
                                onTap: () {
                                  // deviceCreateScreen으로 이동하는 코드
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DeviceCreateScreen(
                                          groupId:
                                              _selectedLocation.toString()),
                                    ),
                                  ).then((result) {
                                    if (result != null) {
                                      fetchDeviceData(
                                          _selectedLocation.toString());
                                    }
                                  });
                                },
                              ),
                              PopupMenuItem(
                                value: '주문 목록',
                                child: const Text('주문 목록'),
                                onTap: () {
                                  Navigator.pushNamed(context, '/orderList',
                                      arguments: _selectedLocation);
                                },
                              ),
                            ],
                            elevation: 8.0,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: SingleChildScrollView(
                child: deviceList.isNotEmpty
                    ? Column(
                        children: deviceList
                            .map((device) => DeviceWidget(
                                  deviceInfo: device,
                                  onDeviceChanged: refreshDevices,
                                  groupId: _selectedLocation.toString(),
                                ))
                            .toList(),
                      )
                    : const Center(child: Text('등록된 기기가 없습니다.')),
              ),
            ),
    );
  }
}
