import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:somoa/screens/device/device_detail_screen.dart';
import 'package:somoa/services/api_services.dart';

class SupplyScreen extends StatefulWidget {
  const SupplyScreen({super.key});

  @override
  _SupplyScreenState createState() => _SupplyScreenState();
}

class _SupplyScreenState extends State<SupplyScreen> {
  bool isLoading = true;
  Map<String, List> careNeedSupply = {};
  Map<String, List> careNotNeedSupply = {};
  late int totalCount;

  // 임시 데이터
  Map<String, dynamic> dummyData = {
    "isCareNeeded": {
      "add": [
        {
          "supplyLimit": {"supplyAmount": 0},
          "supplyName": "세제",
          "groupName": "우리집",
          "supplyId": "6604ff5879b7926a685f879c",
          "supplyType": "washerDetergent",
          "groupId": 1,
          "supplyDetails": {"supplyAmount": 0},
          "supplyAmountTmp": 0,
          "deviceId": "245d1d553e2acd72",
          "deviceNickname": "세탁기"
        },
        {
          "supplyLimit": {"supplyAmount": 0},
          "supplyName": "섬유유연제",
          "groupName": "우리집",
          "supplyId": "6604ff5879b7926a685f879b",
          "supplyType": "fabricSoftener",
          "groupId": 1,
          "supplyDetails": {"supplyAmount": 0},
          "supplyAmountTmp": 0,
          "deviceId": "245d1d553e2acd72",
          "deviceNickname": "세탁기"
        },
        {
          "supplyLimit": {"supplyAmount": 0},
          "supplyName": "섬유유연제",
          "groupName": "친구집",
          "supplyId": "6604ff5a79b7926a685f87aa",
          "supplyType": "fabricSoftener",
          "groupId": 3,
          "supplyDetails": {"supplyAmount": 0},
          "supplyAmountTmp": 0,
          "deviceId": "e93872ca1f6e3e27",
          "deviceNickname": "세탁기"
        },
        {
          "supplyLimit": {"supplyAmount": 0},
          "supplyName": "세제",
          "groupName": "친구집",
          "supplyId": "6604ff5a79b7926a685f87ab",
          "supplyType": "dishDetergent",
          "groupId": 3,
          "supplyDetails": {"supplyAmount": 0},
          "supplyAmountTmp": 0,
          "deviceId": "e93872ca1f6e3e27",
          "deviceNickname": "식기세척기"
        },
        {
          "supplyLimit": {"supplyAmount": 0},
          "supplyName": "세제",
          "groupName": "친구집",
          "supplyId": "6604ff5a79b7926a685f87ac",
          "supplyType": "washerDetergent",
          "groupId": 3,
          "supplyDetails": {"supplyAmount": 0},
          "supplyAmountTmp": 0,
          "deviceId": "e93872ca1f6e3e27",
          "deviceNickname": "세탁기"
        }
      ],
      "change": [
        {
          "supplyLimit": {"supplyChangeDate": 365, "supplyStatus": "bad"},
          "supplyName": "교체형 필터",
          "groupName": "우리집",
          "supplyId": "6604ff5979b7926a685f87a2",
          "supplyType": "replaceableFilter",
          "groupId": 1,
          "supplyDetails": {
            "supplyChangeDate": "2024-03-28T05:25:45.406+00:00",
            "supplyStatus": "good"
          },
          "deviceId": "5e04bd56dfcf7ca0",
          "deviceNickname": "공기청정기"
        },
        {
          "supplyLimit": {"supplyChangeDate": 365, "supplyStatus": "bad"},
          "supplyName": "교체형 필터",
          "groupName": "할머니댁",
          "supplyId": "6604ff5a79b7926a685f87a5",
          "supplyType": "replaceableFilter",
          "groupId": 3,
          "supplyDetails": {
            "supplyChangeDate": "2024-03-28T05:25:46.229+00:00",
            "supplyStatus": "good"
          },
          "deviceId": "e93872ca1f6e3e27",
          "deviceNickname": "공기청정기"
        }
      ],
      "clean": [
        {
          "supplyLimit": {"supplyStatus": 8},
          "supplyName": "먼지봉투",
          "groupName": "우리집",
          "supplyId": "6604ff5979b7926a685f87a1",
          "supplyType": "dustBin",
          "groupId": 1,
          "supplyDetails": {"supplyStatus": 10},
          "deviceId": "5e04bd56dfcf7ca0",
          "deviceNickname": "청소기"
        },
        {
          "supplyLimit": {"supplyChangeDate": 365, "supplyStatus": "bad"},
          "supplyName": "청소형 필터",
          "groupName": "할머니댁",
          "supplyId": "6604ff5a79b7926a685f87a6",
          "supplyType": "cleanableFilter",
          "groupId": 3,
          "supplyDetails": {
            "supplyChangeDate": "2024-03-28T05:25:46.232+00:00",
            "supplyStatus": "good"
          },
          "deviceId": "e93872ca1f6e3e27",
          "deviceNickname": "에어컨"
        },
      ]
    },
    "totalCount": 13,
    "isCareNotNeeded": {
      "add": [
        {
          "supplyLimit": {"supplyLevel": 10},
          "supplyName": "물탱크",
          "groupName": "우리집",
          "supplyId": "6604ff5979b7926a685f87a3",
          "supplyType": "supplyTank",
          "groupId": 1,
          "supplyDetails": {"supplyLevel": 0},
          "deviceId": "c21ba6879d8af9f7",
          "deviceNickname": "가습기"
        },
        {
          "supplyLimit": {"supplyLevel": 10},
          "supplyName": "물탱크",
          "groupName": "할머니댁",
          "supplyId": "6604ff5a79b7926a685f87a7",
          "supplyType": "supplyTank",
          "groupId": 3,
          "supplyDetails": {"supplyLevel": 0},
          "deviceId": "e93872ca1f6e3e27",
          "deviceNickname": "가습기"
        }
      ],
      "change": [],
      "clean": [
        {
          "supplyLimit": {"supplyLevel": 90},
          "supplyName": "물탱크",
          "groupName": "우리집",
          "supplyId": "6604ff5979b7926a685f87a0",
          "supplyType": "drainTank",
          "groupId": 1,
          "supplyDetails": {"supplyLevel": 100},
          "deviceId": "5e04bd56dfcf7ca0",
          "deviceNickname": "제습기"
        },
        {
          "supplyLimit": {"supplyLevel": 90},
          "supplyName": "h",
          "groupName": "Group 3",
          "supplyId": "6604ff5a79b7926a685f87a8",
          "supplyType": "drainTank",
          "groupId": 3,
          "supplyDetails": {"supplyLevel": 100},
          "deviceId": "e93872ca1f6e3e27",
          "deviceNickname": "dddd"
        }
      ]
    }
  };

  Future<void> fetchData() async {
    String serverUrl = dotenv.get("SERVER_URL");
    String? accessToken = await getAccessToken();
    String url = '${serverUrl}supplies/all';

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
            jsonDecode(utf8.decode(response.bodyBytes))['data'];
        int tempTotalCount = responseData['totalCount'] as int;
        if (tempTotalCount > 0) {
          setState(() {
            careNeedSupply =
                Map<String, List>.from(responseData['isCareNeeded']);
            careNotNeedSupply =
                Map<String, List>.from(responseData['isCareNotNeeded']);
            isLoading = false;
            totalCount = tempTotalCount;
          });
        } else {
          setState(() => isLoading = false);
          totalCount = 0;
        }
      } else {
        print(response.body);
        print('Failed to fetch location data: ${response.statusCode}');
        setState(() {
          isLoading = false;
          careNeedSupply = Map<String, List>.from(dummyData['isCareNeeded']);
          careNotNeedSupply =
              Map<String, List>.from(dummyData['isCareNotNeeded']);
          totalCount = dummyData['totalCount'];
        });
      }
    } else {
      print('Access token is null');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    Map careNeedCount = {};
    Map careNotNeedCount = {};
    int careNeedTotal = 0;
    int careNotNeedTotal = 0;

    careNeedSupply.forEach((key, value) {
      careNeedCount[key] = value.length;
      careNeedTotal += value.length;
    });

    careNotNeedSupply.forEach((key, value) {
      careNotNeedCount[key] = value.length;
      careNotNeedTotal += value.length;
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          '소모품 상태 모아보기',
          style: TextStyle(fontSize: 26.0),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : totalCount == 0
              ? Center(child: Text('등록된 소모품이 없습니다.'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                          child: Column(
                            children: [
                              Image.asset(
                                  'assets/images/face=${careNeedTotal == 0 ? "good" : careNeedTotal < careNotNeedTotal ? "normal" : "bad"}.png',
                                  height: 100),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  careNeedTotal == 0
                                      ? "모든 소모품이 \n잘 관리되고 있어요!"
                                      : "관리가 필요한 \n소모품이 있어요.",
                                  style: const TextStyle(fontSize: 22),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text(
                                "$totalCount개의 소모품 중\n $careNeedTotal개가 관리가 필요합니다.",
                                style: const TextStyle(fontSize: 15),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      ),
                      // 교체가 필요한 소모품
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      SizedBox(
                                          width: 30, child: Icon(Icons.cached)),
                                      Text('교체',
                                          style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                  Text(
                                    '${careNeedCount['change']} / ${careNeedCount['change'] + careNotNeedCount['change']}',
                                  ),
                                ],
                              ),
                              for (int i = 0;
                                  i < careNeedSupply['change']!.length;
                                  i++)
                                Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                          '${careNeedSupply['change']![i]['groupName']} > ${careNeedSupply['change']![i]['deviceNickname']} > ${careNeedSupply['change']![i]['supplyName']}'),
                                      trailing: const SizedBox(
                                        width: 5,
                                        child: Icon(Icons.arrow_forward_ios,
                                            color: Colors.black54),
                                      ),
                                      onTap: () {
                                        // 해당 기기 상세페이지로 이동
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DeviceDetailScreen(
                                                    deviceId: careNeedSupply[
                                                            'change']![i]
                                                        ['deviceId']),
                                          ),
                                        ).then((_) {
                                          fetchData();
                                        });
                                      },
                                    ),
                                    if (i !=
                                        careNeedSupply['change']!.length - 1)
                                      Divider(
                                          color: Colors.grey[
                                              400]), // 마지막 아이템이 아닐 때만 Divider 추가
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      // 충전이 필요한 소모품
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      SizedBox(
                                          width: 30,
                                          child:
                                              Icon(Icons.add_circle_outline)),
                                      Text('충전',
                                          style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                  Text(
                                    '${careNeedCount['add']} / ${careNeedCount['add'] + careNotNeedCount['add']}',
                                  ),
                                ],
                              ),
                              for (int i = 0;
                                  i < careNeedSupply['add']!.length;
                                  i++)
                                Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                          '${careNeedSupply['add']![i]['groupName']} > ${careNeedSupply['add']![i]['deviceNickname']} > ${careNeedSupply['add']![i]['supplyName']}'),
                                      trailing: const SizedBox(
                                        width: 5,
                                        child: Icon(Icons.arrow_forward_ios,
                                            color: Colors.black54),
                                      ),
                                      onTap: () {
                                        // 해당 기기 상세페이지로 이동
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DeviceDetailScreen(
                                                    deviceId: careNeedSupply[
                                                        'add']![i]['deviceId']),
                                          ),
                                        ).then((_) {
                                          fetchData();
                                        });
                                      },
                                    ),
                                    if (i != careNeedSupply['add']!.length - 1)
                                      Divider(
                                          color: Colors.grey[
                                              400]), // 마지막 아이템이 아닐 때만 Divider 추가
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      // 청소가 필요한 소모품
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      SizedBox(
                                          width: 30,
                                          child: Icon(Icons.cleaning_services)),
                                      Text('청소',
                                          style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                  Text(
                                    '${careNeedCount['clean']} / ${careNeedCount['clean'] + careNotNeedCount['clean']}',
                                  ),
                                ],
                              ),
                              for (int i = 0;
                                  i < careNeedSupply['clean']!.length;
                                  i++)
                                Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                          '${careNeedSupply['clean']![i]['groupName']} > ${careNeedSupply['clean']![i]['deviceNickname']} > ${careNeedSupply['clean']![i]['supplyName']}'),
                                      trailing: const SizedBox(
                                        width: 5,
                                        child: Icon(Icons.arrow_forward_ios,
                                            color: Colors.black54),
                                      ),
                                      onTap: () {
                                        // 해당 기기 상세페이지로 이동
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DeviceDetailScreen(
                                                    deviceId: careNeedSupply[
                                                            'clean']![i]
                                                        ['deviceId']),
                                          ),
                                        ).then((_) {
                                          fetchData();
                                        });
                                      },
                                    ),
                                    if (i !=
                                        careNeedSupply['clean']!.length - 1)
                                      Divider(
                                          color: Colors.grey[
                                              400]), // 마지막 아이템이 아닐 때만 Divider 추가
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
    );
  }
}

class SupplyItem {
  final String supplyName;
  final String groupName;
  final String supplyId;
  final String supplyType;
  final int groupId;
  final Map<String, dynamic> supplyDetails;
  final Map<String, dynamic> supplyLimit;
  final String deviceId;
  final String deviceNickname;

  SupplyItem({
    required this.supplyLimit,
    required this.supplyName,
    required this.groupName,
    required this.supplyId,
    required this.supplyType,
    required this.groupId,
    required this.supplyDetails,
    required this.deviceId,
    required this.deviceNickname,
  });

  factory SupplyItem.fromJson(Map<String, dynamic> json) {
    return SupplyItem(
      supplyLimit: json['supplyLimit'],
      supplyName: json['supplyName'],
      groupName: json['groupName'],
      supplyId: json['supplyId'],
      supplyType: json['supplyType'],
      groupId: json['groupId'],
      supplyDetails: json['supplyDetails'],
      deviceId: json['deviceId'],
      deviceNickname: json['deviceNickname'],
    );
  }
}
