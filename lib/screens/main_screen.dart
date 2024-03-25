import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:somoa/providers/user_provider.dart';
import 'package:somoa/utils/bottom_navigation_bar.dart';
import 'package:somoa/widgets/device_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  //dotenv을 가져오는 코드
  void getEnv() async {
    await dotenv.load();
    String url = dotenv.get("PROJECT_URL");
  }

  // 임시 데이터 -> 사용자가 포함된 장소 데이터 서버로부터 받아야함 (-> 전역 상태로 저장 후 받아서 써야함)
  static const locationList = ['내 자취방', '부모님집', '할머니댁'];
  late String _selectedLocation;

  // 임시 기기-소모품 데이터
  List<Map<String, Object>> deviceList = [
    {
      "deviceId": 1,
      "deviceNickname": "세탁기",
      "deviceType": "Washer",
      "deviceModel": "최신형 세탁기",
      "supplies": [
        {
          "supplyId": 101,
          "supplyType": "washerDetergent",
          "supplyName": "세탁 세제",
          "supplyDuration": null,
          "supplyStatus": null,
          "supplyAmount": 1000,
          "limit": {"option": "amount", "description": 150},
          "supplyAmountTmp": null
        },
        {
          "supplyId": 102,
          "supplyType": "fabricSoftener",
          "supplyName": "섬유유연제",
          "supplyDuration": null,
          "supplyStatus": null,
          "supplyAmount": 2000,
          "supplyChangeDate": null,
          "limit": {"option": "amount", "description": 100},
          "supplyAmountTmp": null
        }
      ]
    },
    {
      "deviceId": 2,
      "deviceNickname": "가습기",
      "deviceType": "Humidifier",
      "deviceModel": "최신 가습기",
      "supplies": [
        {
          "supplyId": 201,
          "supplyType": "supplyTank",
          "supplyName": "물탱크",
          "supplyDuration": null,
          "supplyStatus": null,
          "supplyAmount": 50,
          "supplyChangeDate": "2024-03-21",
          "limit": {"option": "amount", "description": 5},
          "supplyAmountTmp": null,
        }
      ]
    },
    {
      "deviceId": 3,
      "deviceNickname": "제습기",
      "deviceType": "Dehumidifier",
      "deviceModel": "최신 제습기",
      "supplies": [
        {
          "supplyId": 301,
          "supplyType": "drainTank",
          "supplyName": "물탱크",
          "supplyDuration": null,
          "supplyStatus": null,
          "supplyAmount": 10,
          "supplyChangeDate": "2024-03-21",
          "limit": {"option": "amount", "description": 195},
          "supplyAmountTmp": null,
        }
      ]
    },
    {
      "deviceId": 5,
      "deviceNickname": "공기청정기",
      "deviceType": "airPurifier",
      "deviceModel": "최신 공기청정기",
      "supplies": [
        {
          "supplyId": 501,
          "supplyType": "replaceableFilter",
          "supplyName": "필터",
          "supplyDuration": 6,
          "supplyStatus": "보통",
          "supplyAmount": null,
          "supplyChangeDate": "2024-03-10",
          "limit": {"option": "status", "description": "나쁨"},
          "supplyAmountTmp": null
        }
      ]
    },
    {
      "deviceId": 6,
      "deviceNickname": "에어컨",
      "deviceType": "airConditioner",
      "deviceModel": "최신 에어컨",
      "supplies": [
        {
          "supplyId": 601,
          "supplyType": "cleanableFilter",
          "supplyName": "필터",
          "supplyDuration": null,
          "supplyStatus": "나쁨",
          "supplyAmount": null,
          "supplyChangeDate": "2023-03-21",
          "limit": {"option": "status", "description": "나쁨"},
          "supplyAmountTmp": null
        }
      ]
    },
    {
      "deviceId": 7,
      "deviceNickname": "청소기",
      "deviceType": "vacuumCleaner",
      "deviceModel": "최신 청소기",
      "supplies": [
        {
          "supplyId": 701,
          "supplyType": "cleanableFilter",
          "supplyName": "필터",
          "supplyDuration": null,
          "supplyStatus": "나쁨",
          "supplyAmount": null,
          "supplyChangeDate": "2023-03-21",
          "limit": {"option": "status", "description": "나쁨"},
          "supplyAmountTmp": null
        },
        {
          "supplyId": 702,
          "supplyType": "dustBin",
          "supplyName": "먼지봉투",
          "supplyDuration": null,
          "supplyStatus": null,
          "supplyAmount": 8,
          "supplyChangeDate": "2023-12-21",
          "limit": {"option": "amount", "description": 10},
          "supplyAmountTmp": null
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
        bool isLoggedIn = userProvider.isLoggedIn;

        // 사용자 이름이 없는 경우 로그인 화면으로 이동합니다.
        if (isLoggedIn == false) {
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
                        const PopupMenuItem(
                          value: '장소 추가',
                          child: Text('장소 추가'),
                        ),
                        const PopupMenuItem(
                          value: '장소 관리',
                          child: Text('장소 관리'),
                        ),
                        const PopupMenuItem(
                          value: '기기 추가',
                          child: Text('기기 추가'),
                        ),
                        const PopupMenuItem(
                          value: '주문 목록',
                          child: Text('주문 목록'),
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
          bottomNavigationBar: const BottomNavBar(
            selectedIndex: 0,
          ),
        );
      },
    );
  }
}
