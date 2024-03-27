import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:somoa/providers/user_provider.dart';
import 'package:somoa/widgets/device_widget.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  //dotenv을 가져오는 코드
  void getEnv() async {
    await dotenv.load();
    String url = dotenv.get("SERVER_URL");
  }

  // 임시 데이터 -> 사용자가 포함된 장소 데이터 서버로부터 받아야함 (-> 전역 상태로 저장 후 받아서 써야함)
  static const locationList = ['내 자취방', '부모님집', '할머니댁'];
  late String _selectedLocation;

  // 임시 기기-소모품 데이터
  List<Map<String, Object>> deviceList = [
    {
      "deviceId": "asdf1",
      "deviceNickname": "세탁기",
      "deviceType": "Washer",
      "deviceModel": "최신형 세탁기",
      "manufacturer": "LG",
      "supplies": [
        {
          "id": "6601bb29c4ec1e75ed8670be",
          "type": "washerDetergent",
          "name": "세탁세제",
          "details": {"supplyAmount": 100},
          "limit": {"supplyAmount": 300}
        },
        {
          "id": "6601bb29c4ec1e75ed8670bb",
          "type": "fabricSoftener",
          "name": "섬유유연제",
          "details": {"supplyAmount": 1000},
          "limit": {"supplyAmount": 100}
        },
      ]
    },
    {
      "deviceId": "asdf12",
      "deviceNickname": "가습기",
      "deviceType": "Humidifier",
      "deviceModel": "최신 가습기",
      "manufacturer": "삼성",
      "supplies": [
        {
          "id": "6601bb29c4ec1e75ed8670sd",
          "type": "supplyTank",
          "name": "급수 탱크",
          "details": {
            "supplyChangeDate": "2024-03-25T17:58:01.584+00:00",
            "supplyLevel": 50
          },
          "limit": {"supplyChangeDate": 0, "supplyLevel": 10}
        },
      ]
    },
    {
      "deviceId": "asdf123",
      "deviceNickname": "제습기",
      "deviceType": "Dehumidifier",
      "deviceModel": "최신 제습기",
      "manufacturer": "삼성",
      "supplies": [
        {
          "id": "6601bb29c4ec1e75ed8645sd",
          "type": "drainTank",
          "name": "배수 탱크",
          "details": {
            "supplyChangeDate": "2024-03-25T17:58:01.584+00:00",
            "supplyLevel": 91
          },
          "limit": {"supplyChangeDate": 0, "supplyLevel": 90}
        },
      ]
    },
    {
      "deviceId": "asdf1234",
      "deviceNickname": "공기청정기",
      "deviceType": "airPurifier",
      "deviceModel": "최신 공기청정기",
      "supplies": [
        {
          "id": "6601bb29c4ec1e75ed8670ba",
          "type": "replaceableFilter",
          "name": "교체형 필터",
          "details": {
            "supplyChangeDate": "2024-03-25T17:58:01.580+00:00",
            "supplyStatus": "normal"
          },
          "limit": {"supplyChangeDate": 365, "supplyStatus": "bad"}
        },
      ]
    },
    {
      "deviceId": "asdf12345",
      "deviceNickname": "에어컨",
      "deviceType": "airConditioner",
      "deviceModel": "최신 에어컨",
      "manufacturer": "삼성",
      "supplies": [
        {
          "id": "6601bb29c4ec1e75ed8670bc",
          "type": "cleanableFilter",
          "name": "청소형 필터",
          "details": {
            "supplyChangeDate": "2024-03-25T17:58:01.584+00:00",
            "supplyStatus": "good"
          },
          "limit": {"supplyChangeDate": 365, "supplyStatus": "null"}
        },
      ]
    },
    {
      "deviceId": "asdf123456",
      "deviceNickname": "청소기",
      "deviceType": "vacuumCleaner",
      "deviceModel": "최신 청소기",
      "supplies": [
        {
          "id": "6601bb29c4ec1ewerd8645sd",
          "type": "dustBin",
          "name": "먼지봉투",
          "details": {
            "supplyChangeDate": "2023-03-25T17:58:01.584+00:00",
            "supplyStatus": 7
          },
          "limit": {"supplyChangeDate": 0, "supplyStatus": 9}
        }
      ]
    },
  ];


  @override
  void initState() {
    super.initState();
    _selectedLocation = locationList.first;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // 사용자 이름을 가져옵니다.
        String username = userProvider.username ?? "";

        // 사용자 이름이 없는 경우 로그인 화면으로 이동합니다.
        if (username == "") {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return Container(); // 빈 컨테이너를 반환하여 렌더링하지 않습니다.
        }

        // 사용자 이름이 있는 경우 메인 페이지를 표시합니다.
        return Scaffold(
          appBar: AppBar(
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
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedLocation,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedLocation = newValue ?? '';
                            });
                          },
                          items: locationList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
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
                                        // 확인 버튼을 눌렀을 때의 동작을 구현합니다.
                                        if (placeName.isNotEmpty) {
                                          // 장소 이름이 입력되었을 경우에만 처리합니다.
                                          print('장소 이름: $placeName');
                                          // TODO: 장소 추가 로직을 구현합니다.
                                        }
                                        Navigator.pop(context);
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
                            Navigator.pushNamed(context, '/addDevice');
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
              child: Column(
                children: deviceList
                    .map((device) => DeviceWidget(deviceInfo: device))
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
