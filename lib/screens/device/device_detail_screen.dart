import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:somoa/models/device_model.dart';
import 'package:somoa/models/supply_model.dart';
import 'package:somoa/models/order_model.dart';
import 'package:somoa/screens/device/device_info_screen.dart';
import 'package:somoa/services/api_services.dart';
import 'package:somoa/widgets/menu_bar_widget.dart';
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
  void refresh() {
    fetchDeviceData(widget.deviceId);
  }

  bool isLoading = true;
  late Device deviceInfo;

  List<Order> orders = [];

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
            supply.type == 'drainTank' &&
                details['supplyLevel'] >= limit['supplyLevel']) {
          statusSummary++;
        } else if (
            // 급수 탱크인 경우, 임계치 이하면 관리 필요로 판단
            supply.type == 'supplyTank' &&
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
        if (supply.type == 'dustBin') {
          if (details['supplyStatus'] >= limit['supplyStatus']) {
            statusSummary++;
          }
        } else {
          List<String> statusOrder = ['good', 'normal', 'bad'];
          int detailIndex = statusOrder.indexOf(details['supplyStatus']);
          int limitIndex = statusOrder.indexOf(limit['supplyStatus']);
          if (detailIndex >= limitIndex) {
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

  // device 상세 정보 가져오기
  Future<void> fetchDeviceData(String deviceId) async {
    setState(() {
      isLoading = true;
    });
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

        setState(() {
          deviceInfo = _deviceInfo;
          statusSummary = calculateStatusSummary(deviceInfo);
          fetchOrderData(deviceInfo);
        });
      } else {
        print(response.body);
        print('기기 상세 조회 실패: ${response.statusCode}');
      }
    } else {
      print('Access token is null');
    }
  }

  // 소모품 별 주문 데이터 가져오기
  Future<void> fetchOrderData(Device deviceInfo) async {
    List<Future> fetchTasks = [];

    for (Supply supply in deviceInfo.supplies) {
      String supplyId = supply.id;
      String serverUrl = dotenv.get("SERVER_URL");
      String? accessToken = await getAccessToken();
      String url = '${serverUrl}orders?supply_id=$supplyId&order_status=배송 중';

      var fetchTask = http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ).then((response) {
        if (response.statusCode == 200) {
          final String decodedBody = utf8.decode(response.bodyBytes);
          final data = json.decode(decodedBody);
          if (data['data'] != null) {
            final List<dynamic> ordersJson = data['data'];
            return ordersJson.map((order) => Order.fromJson(order)).toList();
          }
        } else {
          print('Supply ID $supplyId에 대한 주문내역 조회 실패: ${response.statusCode}');
        }
      }).catchError((e) {
        print('Supply ID $supplyId에 대한 주문내역 조회 실패: $e');
      });

      fetchTasks.add(fetchTask);
    }

    // 모든 주문 데이터 요청을 기다림
    final results = await Future.wait(fetchTasks);

    // null이 아닌 결과만 필터링하여 주문 리스트 업데이트
    setState(() {
      orders = results
          .where((result) => result != null)
          .expand((result) => result as List) // 각 결과를 List로 캐스팅
          .map((item) => item as Order) // 각 아이템을 Order로 캐스팅
          .toList();
      isLoading = false;
    });
  }

  Map<String, Object> makeOrderInfo(Order order) {
    return {
      'orderStore': order.orderStore,
      'productName': order.productName,
      'productImg': order.productImg,
      'orderStatus': order.orderStatus,
    };
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
          barrierDismissible: false,
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
                    height: 100,
                    child: Image.asset(
                      'assets/images/face=good.png',
                    )),
              ),
              const Text(
                '모든 소모품이 \n 잘 관리되고 있어요!',
                style: TextStyle(fontSize: 22),
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

  void _changeDeviceName(String deviceName) async {
    var bodyData = jsonEncode({
      "deviceName": deviceName,
    });

    String serverUrl = dotenv.get("SERVER_URL");
    String? accessToken = await getAccessToken();

    if (accessToken != null) {
      Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      http.Response response = await http.patch(
        Uri.parse('${serverUrl}devices/${deviceInfo.id}'),
        headers: headers,
        body: bodyData,
      );

      if (response.statusCode == 200) {
        await fetchDeviceData(widget.deviceId);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('$deviceName로 변경 되었습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      } else {
        print(response.body);
        print('기기 이름 변경 실패: ${response.statusCode}');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('기기 이름 변경에 실패했습니다.'),
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
    return Scaffold(
      appBar: isLoading ? MenuBarWidget(titleText: '') :
      MenuBarWidget(
        titleText: isLoading ? '' : deviceInfo.nickname,
        showExtraMenu: true,
        buildPopupMenuButton: () {
          return PopupMenuButton<String>(
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
              PopupMenuItem<String>(
                child: const Text('이름 변경'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      String deviceName = '';
                      return AlertDialog(
                        title: const Text(
                          '기기 이름 변경',
                          textAlign: TextAlign.center,
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              onChanged: (value) {
                                deviceName = value;
                              },
                              decoration: const InputDecoration(
                                  hintText: "변경할 이름 입력",
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black))),
                            ),
                          ],
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              if (deviceName.isNotEmpty) {
                                _changeDeviceName(deviceName);
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
              PopupMenuItem<String>(
                child:
                    const Text('기기 삭제', style: TextStyle(color: Colors.red)),
                onTap: () {
                  deleteDevice(context, deviceInfo.id);
                },
              ),
            ],
          );
        },
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
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.start,
                          ),
                          for (var order in orders)
                            OrderWidget(orderInfo: makeOrderInfo(order)),
                        ],
                      ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '소모품 목록',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.start,
                        ),
                        if (deviceInfo.supplies.isNotEmpty)
                          ...deviceInfo.supplies.map((supply) => SupplyWidget(
                                deviceId: deviceInfo.id,
                                supplyInfo: supply,
                                onRefresh: refresh,
                              ))
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
