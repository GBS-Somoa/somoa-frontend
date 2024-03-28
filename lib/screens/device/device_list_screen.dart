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

  // 임시 기기-소모품 데이터
  // List<Map<String, Object>> deviceList = [
  //   {
  //     "deviceId": "asdf1",
  //     "deviceNickname": "세탁기",
  //     "deviceType": "Washer",
  //     "deviceModel": "최신형 세탁기",
  //     "manufacturer": "LG",
  //     "supplies": [
  //       {
  //         "id": "6601bb29c4ec1e75ed8670be",
  //         "type": "washerDetergent",
  //         "name": "세탁세제",
  //         "details": {"supplyAmount": 100},
  //         "limit": {"supplyAmount": 300}
  //       },
  //       {
  //         "id": "6601bb29c4ec1e75ed8670bb",
  //         "type": "fabricSoftener",
  //         "name": "섬유유연제",
  //         "details": {"supplyAmount": 1000},
  //         "limit": {"supplyAmount": 100}
  //       },
  //     ]
  //   },
  //   {
  //     "deviceId": "asdf12",
  //     "deviceNickname": "가습기",
  //     "deviceType": "Humidifier",
  //     "deviceModel": "최신 가습기",
  //     "manufacturer": "삼성",
  //     "supplies": [
  //       {
  //         "id": "6601bb29c4ec1e75ed8670sd",
  //         "type": "supplyTank",
  //         "name": "급수 탱크",
  //         "details": {
  //           "supplyChangeDate": "2024-03-25T17:58:01.584+00:00",
  //           "supplyLevel": 50
  //         },
  //         "limit": {"supplyChangeDate": 0, "supplyLevel": 10}
  //       },
  //     ]
  //   },
  //   {
  //     "deviceId": "asdf123",
  //     "deviceNickname": "제습기",
  //     "deviceType": "Dehumidifier",
  //     "deviceModel": "최신 제습기",
  //     "manufacturer": "삼성",
  //     "supplies": [
  //       {
  //         "id": "6601bb29c4ec1e75ed8645sd",
  //         "type": "drainTank",
  //         "name": "배수 탱크",
  //         "details": {
  //           "supplyChangeDate": "2024-03-25T17:58:01.584+00:00",
  //           "supplyLevel": 91
  //         },
  //         "limit": {"supplyChangeDate": 0, "supplyLevel": 90}
  //       },
  //     ]
  //   },
  //   {
  //     "deviceId": "asdf1234",
  //     "deviceNickname": "공기청정기",
  //     "deviceType": "airPurifier",
  //     "deviceModel": "최신 공기청정기",
  //     "supplies": [
  //       {
  //         "id": "6601bb29c4ec1e75ed8670ba",
  //         "type": "replaceableFilter",
  //         "name": "교체형 필터",
  //         "details": {
  //           "supplyChangeDate": "2024-03-25T17:58:01.580+00:00",
  //           "supplyStatus": "normal"
  //         },
  //         "limit": {"supplyChangeDate": 365, "supplyStatus": "bad"}
  //       },
  //     ]
  //   },
  //   {
  //     "deviceId": "asdf12345",
  //     "deviceNickname": "에어컨",
  //     "deviceType": "airConditioner",
  //     "deviceModel": "최신 에어컨",
  //     "manufacturer": "삼성",
  //     "supplies": [
  //       {
  //         "id": "6601bb29c4ec1e75ed8670bc",
  //         "type": "cleanableFilter",
  //         "name": "청소형 필터",
  //         "details": {
  //           "supplyChangeDate": "2024-03-25T17:58:01.584+00:00",
  //           "supplyStatus": "good"
  //         },
  //         "limit": {"supplyChangeDate": 365, "supplyStatus": "null"}
  //       },
  //     ]
  //   },
  //   {
  //     "deviceId": "asdf123456",
  //     "deviceNickname": "청소기",
  //     "deviceType": "vacuumCleaner",
  //     "deviceModel": "최신 청소기",
  //     "supplies": [
  //       {
  //         "id": "6601bb29c4ec1ewerd8645sd",
  //         "type": "dustBin",
  //         "name": "먼지봉투",
  //         "details": {
  //           "supplyChangeDate": "2023-03-25T17:58:01.584+00:00",
  //           "supplyStatus": 7
  //         },
  //         "limit": {"supplyChangeDate": 0, "supplyStatus": 9}
  //       }
  //     ]
  //   },
  // ];

  @override
  void initState() {
    super.initState();
    locationList = [];
    _selectedLocation = 0;
    fetchLocationData();
  }

  // 사용자가 포함된 그룹 리스트 가져오는 코드
  Future<void> fetchLocationData() async {
    // .env 파일에서 서버 URL을 가져옵니다.
    String serverUrl = dotenv.get("SERVER_URL");
    String? accessToken = await getAccessToken();
    print(accessToken);

    // accessToken이 있는 경우에만 요청을 보냅니다.
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
          // print(locationList);
          // print(_selectedLocation);
        });
        // print(responseData);
      } else {
        print(response.body);
        print('Failed to fetch location data: ${response.statusCode}');
      }
    } else {
      print('Access token is null');
    }
  }

  void _registerLoctaion(String groupName) async {
    var bodyData = jsonEncode({
      "groupName": groupName,
    });

    // .env 파일에서 서버 URL을 가져옵니다.
    String serverUrl = dotenv.get("SERVER_URL");
    String? accessToken = await getAccessToken();

    // accessToken이 있는 경우에만 요청을 보냅니다.
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
        Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('$groupName 장소가 추가 되었습니다.'),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/main'),
                child: const Text('확인'),
              ),
            ],
          ),
        );
        print(responseData);
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
    String serverUrl = dotenv.get("SERVER_URL");
    String? accessToken = await getAccessToken();
    String url = '${serverUrl}groups/$groupId/devices';

    // accessToken이 있는 경우에만 요청을 보냅니다.
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
        // print(tmpDeviceList);
        setState(() {
          deviceList = devices;
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.home),
                SizedBox(
                  width: 150.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedLocation,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedLocation = newValue!;
                          fetchDeviceData(_selectedLocation.toString());
                        });
                      },
                      items: locationList.map<DropdownMenuItem<int>>((value) {
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
                                                color: Colors.black))),
                                  ),
                                ],
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (placeName.isNotEmpty) {
                                      // 장소 이름이 입력되었을 경우에만 처리합니다.
                                      _registerLoctaion(placeName);
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
                        Navigator.pushNamed(context, '/locationDetail');
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
                                groupId: _selectedLocation.toString()),
                          ),
                        );
                      },
                    ),
                    PopupMenuItem(
                      value: '주문 목록',
                      child: const Text('주문 목록'),
                      onTap: () {
                        Navigator.pushNamed(context, '/orderList');
                      },
                    ),
                  ],
                  elevation: 8.0,
                ).then((value) {
                  if (value != null) {
                    // Handle menu item selection here
                    print('Selected: $value');
                  }
                });
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: deviceList.isNotEmpty
              ? Column(
                  children: deviceList
                      .map((device) => DeviceWidget(deviceInfo: device))
                      .toList(),
                )
              : const Center(child: Text('등록된 기기가 없습니다.')),
        ),
      ),
    );
  }
}
