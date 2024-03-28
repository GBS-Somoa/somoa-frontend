import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:somoa/screens/device/device_info_screen.dart';
import 'package:somoa/services/api_services.dart';
import 'package:somoa/widgets/order_widget.dart';
import 'dart:convert';

import 'package:somoa/widgets/supply_widget.dart';

class DeviceDetailScreen extends StatefulWidget {
  final String deviceId;

  DeviceDetailScreen({super.key, required this.deviceId});

  @override
  _DeviceDetailScreenState createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  bool isLoading = true;
  late Device deviceInfo;

  // 더미 기기 데이터
  // Map<String, Object> dummyData = {
  //   "id": "06b76c4725ddc59b",
  //   "nickname": "dd",
  //   "model": "가나다라",
  //   "type": "washer",
  //   "manufacturer": "LG",
  //   "supplies": [
  //     {
  //       "id": "6601bb29c4ec1e75ed8670bb",
  //       "type": "fabricSoftener",
  //       "name": "섬유유연제",
  //       "details": {"supplyAmount": 1000},
  //       "limit": {"supplyAmount": 100},
  //       'supplyAmountTmp': 0,
  //     },
  //     {
  //       "id": "6601bb29c4ec1e75ed8670ba",
  //       "type": "replaceableFilter",
  //       "name": "교체형 필터",
  //       "details": {
  //         "supplyChangeDate": "2024-03-25T17:58:01.580+00:00",
  //         "supplyStatus": "normal"
  //       },
  //       "limit": {"supplyChangeDate": 365, "supplyStatus": "bad"}
  //     },
  //     {
  //       "id": "6601bb29c4ec1e75ed8670be",
  //       "type": "washerDetergent",
  //       "name": "세탁세제",
  //       "details": {"supplyAmount": 100},
  //       "limit": {"supplyAmount": 300},
  //       'supplyAmountTmp': 0,
  //     },
  //     {
  //       "id": "6601bb29c4ec1e75ed8670bf",
  //       "type": "dishRinse",
  //       "name": "식기세척기 린스",
  //       "details": {"supplyAmount": 100},
  //       "limit": {"supplyAmount": 0},
  //       'supplyAmountTmp': 500,
  //     },
  //     {
  //       "id": "6601bb29c4ec1e75ed8670bd",
  //       "type": "dishDetergent",
  //       "name": "세제",
  //       "details": {"supplyAmount": 0},
  //       "limit": {"supplyAmount": 0},
  //       'supplyAmountTmp': 2000,
  //     },
  //     {
  //       "id": "6601bb29c4ec1e75ed8670bc",
  //       "type": "cleanableFilter",
  //       "name": "청소형 필터",
  //       "details": {
  //         "supplyChangeDate": "2024-03-25T17:58:01.584+00:00",
  //         "supplyStatus": "good"
  //       },
  //       "limit": {"supplyChangeDate": 365, "supplyStatus": "null"}
  //     },
  //     {
  //       "id": "6601bb29c4ec1e75ed8670sd",
  //       "type": "supplyTank",
  //       "name": "급수 탱크",
  //       "details": {
  //         "supplyChangeDate": "2024-03-25T17:58:01.584+00:00",
  //         "supplyLevel": 50
  //       },
  //       "limit": {"supplyChangeDate": 0, "supplyLevel": 10}
  //     },
  //     {
  //       "id": "6601bb29c4ec1e75ed8645sd",
  //       "type": "drainTank",
  //       "name": "배수 탱크",
  //       "details": {
  //         "supplyChangeDate": "2024-03-25T17:58:01.584+00:00",
  //         "supplyLevel": 95
  //       },
  //       "limit": {"supplyChangeDate": 0, "supplyLevel": 90}
  //     },
  //     {
  //       "id": "6601bb29c4ec1ewerd8645sd",
  //       "type": "dustBin",
  //       "name": "먼지봉투",
  //       "details": {
  //         "supplyChangeDate": "2023-03-25T17:58:01.584+00:00",
  //         "supplyStatus": 7
  //       },
  //       "limit": {"supplyChangeDate": 0, "supplyStatus": 9}
  //     }
  //   ]
  // };

  // 임시 기기와 연관된 소모품 주문 데이터
  List<Map<String, Object>> orders = [
    {
      "orderId": 0,
      "orderStore": "SSAPANG",
      "productName": "다우니 세제 1L",
      "orderDate": "2024-03-25",
      "orderStatus": "배송완료"
    },
    {
      "orderId": 1,
      "orderStore": "SSAPANG",
      "productName": "다우니 세제 1L",
      "orderDate": "2024-03-25",
      "orderStatus": "결제완료"
    },
    {
      "orderId": 2,
      "orderStore": "삼성몰",
      "productName": "어쩌구저쩌구 정품 필터",
      "orderDate": "2024-03-25",
      "orderStatus": "결제완료"
    },
  ];

  int statusSummary = 0;

  int calculateStatusSummary(dynamic deviceInfo) {
    int statusSummary = 0;

    List supplies = deviceInfo.supplies;
    DateTime today = DateTime.now();

    supplies.forEach((supply) {
      Map<String, dynamic> details = supply.details;
      Map<String, dynamic> limit = supply.limit;

      if (details.containsKey('supplyAmount') &&
          limit.containsKey('supplyAmount')) {
        if (
            // 다른 것들은 limit 보다 작으면 관리 필요로 판단
            details['supplyAmount'] <= limit['supplyAmount']) {
          statusSummary++;
        }
      }

      if (details.containsKey('supplyLevel') &&
          limit.containsKey('supplyLevel')) {
        if (
            // 배수 탱크인 경우, 임계치 이상이면 관리 필요로 판단
            supply['type'] == 'drainTank' &&
                details['supplyLevel'] >= limit['supplyLevel']) {
          statusSummary++;
        } else if (
            // 급수 탱크인 경우, 임계치 이하면 관리 필요로 판단
            supply['type'] == 'supplyTank' &&
                details['supplyLevel'] <= limit['supplyLevel']) {
          statusSummary++;
        }
      }

      if (details.containsKey('supplyChangeDate') &&
          limit.containsKey('supplyChangeDate')) {
        DateTime supplyChangeDate = DateTime.parse(details['supplyChangeDate']);
        int daysDifference = today.difference(supplyChangeDate).inDays;
        if (daysDifference >= limit['supplyChangeDate']) {
          statusSummary++;
        }
      }

      if (details.containsKey('supplyStatus') &&
          limit.containsKey('supplyStatus')) {
        if (supply['type'] == 'dustBin') {
          if (details['supplyStatus'] >= limit['supplyStatus']) {
            statusSummary++;
          }
        } else {
          List<String> statusOrder = ['good', 'normal', 'bad'];
          int detailIndex = statusOrder.indexOf(details['supplyStatus']);
          int limitIndex = statusOrder.indexOf(limit['supplyStatus']);
          if (detailIndex <= limitIndex) {
            statusSummary++;
          }
        }
      }
    });

    return statusSummary;
  }

  @override
  void initState() {
    super.initState();
    fetchDeviceData(widget.deviceId);
  }

  Future<void> fetchDeviceData(String deviceId) async {
    String serverUrl = dotenv.get("SERVER_URL");
    String? accessToken = await getAccessToken();
    String url = '${serverUrl}devices/$deviceId';

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

        Device _deviceInfo = Device.fromJson(responseData);
        print(_deviceInfo.nickname);
        setState(() {
          deviceInfo = _deviceInfo;
          isLoading = false;
          statusSummary = calculateStatusSummary(deviceInfo);
        });
      } else {
        print(response.body);
        print('Failed to fetch location data: ${response.statusCode}');
      }
    } else {
      print('Access token is null');
    }
  }

  Future<void> fetchOrderData(String stringId) async {
    // /api/orders?supply_id={supply_id}&order_status=배송중
    // device에 포함된 supplyid 순회하면서 조회하고 list로 합치기
  }

  void deleteDevice(BuildContext context, String deviceId) async {
    String serverUrl = dotenv.get("SERVER_URL");
    String? accessToken = await getAccessToken();
    String url = '${serverUrl}devices/$deviceId';

    try {
      final response = await http.delete(Uri.parse(url),
          headers: {"Authorization": "Bearer $accessToken"});

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('삭제 성공'),
              content: const Text('기기가 삭제되었습니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/main');
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('에러'),
              content: Text('기기 삭제에 문제 실패: $response.body.data'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('에러'),
            content: Text('기기 삭제에 문제 실패: $error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _statusSummaryWidget(statusSummary) {
    return statusSummary == 0
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                    height: 120,
                    child: Image.asset(
                      'assets/images/face=good.png',
                    )),
              ),
              const Text(
                '모든 소모품이 \n 잘 관리되고 있어요!',
                style: TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              )
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                    height: 120,
                    child: Image.asset('assets/images/face=bad.png')),
              ),
              const Text(
                '관리가 필요한 \n 소모품이 있어요.',
                style: TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              )
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: isLoading
              ? const Text('Loading...', style: const TextStyle(fontSize: 28))
              : Text(deviceInfo.nickname, style: const TextStyle(fontSize: 28)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamed(context, '/main');
            },
          ),
          actions: [
            PopupMenuButton<String>(
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  child: const Text('기기 정보'),
                  onTap: () {
                    // deviceInfoScreen으로 이동하는 코드
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeviceInfoScreen(
                          deviceInfo: deviceInfo,
                        ),
                      ),
                    );
                  },
                ),
                const PopupMenuItem<String>(
                  child: Text('이름 변경'),
                ),
                PopupMenuItem<String>(
                  child:
                      const Text('기기 삭제', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    deleteDevice(context, deviceInfo.id);
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
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _statusSummaryWidget(statusSummary),
                    const SizedBox(height: 30),
                    if (orders.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            '진행중인 배송',
                            textAlign: TextAlign.start,
                          ),
                          for (var order in orders)
                            OrderWidget(orderInfo: order),
                        ],
                      ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '소모품 목록',
                          textAlign: TextAlign.start,
                        ),
                        if (deviceInfo.supplies.isNotEmpty)
                          ...deviceInfo.supplies.map((supply) => SupplyWidget(
                              deviceId: deviceInfo.id, supplyInfo: supply))
                        else
                          const SizedBox(
                              height: 50,
                              child: Center(child: Text('소모품 정보 없음'))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class Device {
  final String id;
  final String nickname;
  final String type;
  final String model;
  final String manufacturer;
  final List<Supply> supplies;

  Device({
    required this.id,
    required this.nickname,
    required this.type,
    required this.model,
    required this.manufacturer,
    required this.supplies,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      nickname: json['nickname'],
      type: json['type'],
      model: json['model'],
      manufacturer: json['manufacturer'],
      supplies: (json['supplies'] as List<dynamic>)
          .map((supplyJson) => Supply.fromJson(supplyJson))
          .toList(),
    );
  }
}

class Supply {
  final String id;
  final String type;
  final String name;
  final Map<String, dynamic> details;
  final Map<String, dynamic> limit;
  final String? supplyAmountTmp;

  Supply({
    required this.id,
    required this.type,
    required this.name,
    required this.details,
    required this.limit,
    this.supplyAmountTmp,
  });

  factory Supply.fromJson(Map<String, dynamic> json) {
    return Supply(
        id: json['id'],
        type: json['type'],
        name: json['name'],
        details: json['details'],
        limit: json['limit'],
        supplyAmountTmp: json['supplyAmountTmp']);
  }
}
