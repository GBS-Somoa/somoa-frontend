import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:somoa/screens/device/device_info_screen.dart';
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

  Map<String, Object> data = {};

  Map<String, Object> dummyData = {
    "id": "06b76c4725ddc59b",
    "nickname": "dd",
    "model": "가나다라",
    "type": "washer",
    "manufacturer": "LG",
    "supplies": [
      {
        "id": "6601bb29c4ec1e75ed8670bb",
        "type": "fabricSoftener",
        "name": "섬유유연제",
        "details": {"supplyAmount": 1000},
        "limit": {"supplyAmount": 100}
      },
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
      {
        "id": "6601bb29c4ec1e75ed8670be",
        "type": "washerDetergent",
        "name": "세탁세제",
        "details": {"supplyAmount": 100},
        "limit": {"supplyAmount": 300}
      },
      {
        "id": "6601bb29c4ec1e75ed8670bf",
        "type": "dishRinse",
        "name": "식기세척기 린스",
        "details": {"supplyAmount": 0},
        "limit": {"supplyAmount": 0}
      },
      {
        "id": "6601bb29c4ec1e75ed8670bd",
        "type": "dishDetergent",
        "name": "세제",
        "details": {"supplyAmount": 0},
        "limit": {"supplyAmount": 0}
      },
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
  };

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

  int calculateStatusSummary(Map<String, Object> data) {
    int statusSummary = 0;

    List supplies = data['supplies'] as List;
    DateTime today = DateTime.now();

    supplies.forEach((supply) {
      Map<String, dynamic> details = supply['details'];
      Map<String, dynamic> limit = supply['limit'];

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
    fetchDeviceInfo();
  }

  Future<void> fetchDeviceInfo() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Send device lookup request to the server
      final response = await http
          .get(Uri.parse('YOUR_DEVICE_LOOKUP_API_URL/${widget.deviceId}'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        setState(() {
          data = responseData;
          isLoading = false;
          statusSummary = calculateStatusSummary(responseData);
        });
      } else {
        throw Exception('Failed to fetch device info');
      }
    } catch (error) {
      print(error);
      setState(() {
        data = dummyData;
        isLoading = false;
        statusSummary = calculateStatusSummary(dummyData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // toolbarHeight: 100,
        // elevation: 10,
        title: Text('${data['nickname'] ?? '이름 없는 기기'}',
            style: const TextStyle(fontSize: 30)),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                child: const Text('기기 정보'),
                onTap: () {
                  // deviceDetailScreen으로 이동하는 코드
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeviceInfoScreen(
                        deviceInfo: data,
                      ),
                    ),
                  );
                },
              ),
              const PopupMenuItem<String>(
                child: Text('이름 변경'),
              ),
              const PopupMenuItem<String>(
                child: Text('기기 삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
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
                    Center(
                      child: Image.asset(
                        statusSummary == 0
                            ? 'assets/images/face=good.png'
                            : 'assets/images/face=bad.png',
                        height: 160, // Specify height
                      ),
                    ),
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
                        for (var supply in data['supplies'] as List)
                          SupplyWidget(supplyInfo: supply),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
