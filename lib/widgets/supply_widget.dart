import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:somoa/screens/device/device_detail_screen.dart';

class SupplyWidget extends StatelessWidget {
  final String deviceId;
  final dynamic supplyInfo;

  const SupplyWidget({
    super.key,
    required this.deviceId,
    required this.supplyInfo,
  });

  Future<String?> getAccessToken() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'accessToken');
  }

  @override
  Widget build(BuildContext context) {
    void fetchData() async {
      String? accessToken = await getAccessToken();
      print(accessToken);
    }

    switch (supplyInfo.type) {
      case 'washerDetergent':
      case 'fabricSoftener':
      case 'dishDetergent':
      case 'dishRinse':
        return FutureBuilder<Widget>(
          future: _buildDetergentCard(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return snapshot.data!;
            } else {
              return CircularProgressIndicator();
            }
          },
        );
      case 'cleanableFilter':
      case 'replaceableFilter':
        return _buildFilterCard(context);
      case 'supplyTank':
      case 'drainTank':
        return _buildTankCard(context);
      case 'dustBin':
        return _buildDustBinCard(context);
      default:
        return const SizedBox();
    }
  }

  // shared preference 저장소에서 supplyId에 해당하는 maxAmount 값을 가져오는 함수 -> 저장된 값이 없으면 1000으로 저장 & 가져옴
  static Future<int> getMaxAmount(supplyId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = "maxAmount_$supplyId";
    int? maxAmount = prefs.getInt(key);
    if (maxAmount == null) {
      setMaxAmount(supplyId, 1000);
    }
    return maxAmount ?? 1000;
  }

  // shared preference 저장소에서 supplyId에 해당하는 maxAmount 값을 저장하는 함수
  static Future<void> setMaxAmount(String supplyId, int maxAmount) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = "maxAmount_$supplyId";
    await prefs.setInt(key, maxAmount);
  }

  Future<Widget> _buildDetergentCard(BuildContext context) async {
    // 기기 내부에 저장된 데이터에서 supplyId에 맞는 maxAmount를 가져옴
    int maxAmount = await getMaxAmount(supplyInfo.username);

    print(supplyInfo.supplyAmountTmp);
    bool isSupplyAmountTmp =
        supplyInfo.supplyAmountTmp != null && supplyInfo.supplyAmountTmp != 0
            ? true
            : false;

    if (isSupplyAmountTmp) {
      maxAmount = maxAmount + (supplyInfo.supplyAmountTmp as int);
    }

    int supplyAmount = supplyInfo.details['supplyAmount'];
    int limitAmount = supplyInfo.limit['supplyAmount'];
    if (maxAmount < supplyAmount) {
      setMaxAmount(supplyInfo.username, supplyAmount);
      maxAmount = supplyAmount;
    }

    double supplyPercentage = supplyAmount / maxAmount;
    double limitPercentage = limitAmount / maxAmount;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(supplyInfo.name),
                isSupplyAmountTmp
                    ? Text('${supplyAmount}(+${supplyInfo.supplyAmountTmp})ml')
                    : Text('${supplyAmount}ml'),
              ],
            ),
          ),
          // 보유량 막대바
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SizedBox(
              height: 40,
              width: 300,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      height: 20,
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: isSupplyAmountTmp
                                  ? Colors.lightGreen[200]
                                  : Color.fromARGB(255, 219, 219, 219),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: supplyPercentage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: supplyAmount > limitAmount
                                    ? Colors.lightGreen[500]
                                    : Colors.red[400],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(10.0),
                                  bottomLeft: const Radius.circular(10.0),
                                  topRight: Radius.circular(
                                      supplyPercentage == 1 ? 10.0 : 0.0),
                                  bottomRight: Radius.circular(
                                      supplyPercentage == 1 ? 10.0 : 0.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 300 * limitPercentage,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      height: 30,
                      color: Colors.black,
                    ),
                  ),
                  Positioned(
                    left: (300 * limitPercentage) + 5, // Adjusted left position
                    top: 0,
                    child: Text(
                      '${limitAmount}ml',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  buttonMinWidth: 130,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _showSupplyAmountChangeDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                      ),
                      child: const Text(
                        '보유량 변경',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        print('알림 기준 수정 기능 없음ㅎㅎ');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                      ),
                      child: const Text(
                        '알림 기준 수정',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add functionality to purchase consumables button
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    minimumSize: const Size(260, 40),
                  ),
                  child: Text(
                    '${supplyInfo.name} 구매하러 가기',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard(BuildContext context) {
    final String supplyStatus =
        supplyInfo.details['supplyStatus'].toString().toLowerCase();
    final String limitStatus =
        supplyInfo.limit['supplyStatus'].toString().toLowerCase();

    double maxAmount = 1.0;

    double supplyAmount = supplyStatus == 'bad'
        ? 0.33
        : supplyStatus == 'normal'
            ? 0.67
            : supplyStatus == 'good'
                ? 1.0
                : 0.0;

    double limitAmount = limitStatus == 'bad'
        ? 0.33
        : limitStatus == 'normal'
            ? 0.67
            : limitStatus == 'good'
                ? 1.0
                : 0.0;

    double supplyPercentage = supplyAmount / maxAmount;
    double limitPercentage = limitAmount / maxAmount;

    DateTime? givenDateTime =
        DateTime.parse(supplyInfo.details['supplyChangeDate']);

    // 'yyyy-MM-dd' 형식으로 날짜를 포맷
    String? formattedDate = DateFormat("yyyy-MM-dd").format(givenDateTime);

    // 현재 날짜와의 차이 계산
    DateTime currentDate = DateTime.now();
    Duration? difference = currentDate.difference(givenDateTime);

    String changedDateString = supplyInfo.type == 'cleanableFilter'
        ? '최근 청소 날짜 : $formattedDate (${difference.inDays}일 경과)'
        : '최근 교체 날짜 : $formattedDate (${difference.inDays}일 경과)';

    bool isDurationOver =
        difference.inDays >= supplyInfo.limit['supplyChangeDate']
            ? true
            : false;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(supplyInfo.name),
                Text(supplyStatus == 'bad'
                    ? '관리 필요'
                    : supplyStatus == 'normal'
                        ? '상태 보통'
                        : supplyStatus == 'good'
                            ? '상태 좋음'
                            : '알 수 없음'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SizedBox(
              height: 40,
              width: 300,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      height: 20,
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 219, 219, 219),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: supplyPercentage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: supplyStatus == 'bad'
                                    ? Colors.red[400]
                                    : supplyStatus == 'normal'
                                        ? Colors.orange
                                        : supplyStatus == 'good'
                                            ? Colors.lightGreen[500]
                                            : Colors.transparent,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(10.0),
                                  bottomLeft: const Radius.circular(10.0),
                                  topRight: Radius.circular(
                                      supplyPercentage == 1 ? 10.0 : 0.0),
                                  bottomRight: Radius.circular(
                                      supplyPercentage == 1 ? 10.0 : 0.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 300 * 0.33,
                    bottom: 2,
                    child: Container(
                      width: 2,
                      height: 23,
                      color: Colors.black,
                    ),
                  ),
                  Positioned(
                    left: 300 * 0.66,
                    bottom: 2,
                    child: Container(
                      width: 2,
                      height: 23,
                      color: Colors.black,
                    ),
                  ),
                  Positioned(
                    left: limitPercentage != 0
                        ? (300 * limitPercentage) - 11
                        : -20,
                    top: -5,
                    child: const Icon(Icons.arrow_drop_down),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              height: 20,
              child: Text(
                changedDateString,
                style: TextStyle(
                    fontSize: 14,
                    color: isDurationOver ? Colors.red : Colors.black),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  buttonMinWidth: 130,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Add functionality to edit notification criteria button
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                      ),
                      child: const Text(
                        '알림 기준 수정',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                supplyInfo.type == 'cleanableFilter'
                    ? const SizedBox()
                    : ElevatedButton(
                        onPressed: () {
                          // Add functionality to purchase consumables button
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          minimumSize: const Size(260, 40),
                        ),
                        child: Text(
                          '${supplyInfo.name} 구매하러 가기',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTankCard(BuildContext context) {
    int maxAmount = 100;

    int supplyAmount = supplyInfo.details['supplyLevel'];
    int limitAmount = supplyInfo.limit['supplyLevel'];

    double supplyPercentage = supplyAmount / maxAmount;
    double limitPercentage = limitAmount / maxAmount;

    DateTime? givenDateTime =
        DateTime.parse(supplyInfo.details['supplyChangeDate']);

    // 'yyyy-MM-dd' 형식으로 날짜를 포맷
    String? formattedDate = DateFormat("yyyy-MM-dd").format(givenDateTime);

    // 현재 날짜와의 차이 계산
    DateTime currentDate = DateTime.now();
    Duration? difference = currentDate.difference(givenDateTime);

    String changedDateString =
        '최근 교체 날짜 : $formattedDate (${difference.inDays}일 경과)';

    bool isDurationOver =
        difference.inDays >= supplyInfo.limit['supplyChangeDate']
            ? true
            : false;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(supplyInfo.name),
                Text('$supplyAmount%'),
              ],
            ),
          ),
          // 수위 막대바
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SizedBox(
              height: 40,
              width: 300,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      height: 20,
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 219, 219, 219),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: supplyPercentage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: supplyInfo.type == 'supplyTank'
                                    ? (supplyAmount >= limitAmount
                                        ? Colors.blue[500]
                                        : Colors.red[400])
                                    : (supplyAmount <= limitAmount
                                        ? Colors.blue[500]
                                        : Colors.red[400]),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(10.0),
                                  bottomLeft: const Radius.circular(10.0),
                                  topRight: Radius.circular(
                                      supplyPercentage == 1 ? 10.0 : 0.0),
                                  bottomRight: Radius.circular(
                                      supplyPercentage == 1 ? 10.0 : 0.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 300 * limitPercentage,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      height: 30,
                      color: Colors.black,
                    ),
                  ),
                  Positioned(
                    left: (300 * limitPercentage) + 5, // Adjusted left position
                    top: 0,
                    child: Text(
                      '$limitAmount%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              height: 20,
              child: Text(
                changedDateString,
                style: TextStyle(
                    fontSize: 14,
                    color: isDurationOver ? Colors.red : Colors.black),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  buttonMinWidth: 130,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Add functionality to edit notification criteria button
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                      ),
                      child: const Text(
                        '알림 기준 수정',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDustBinCard(BuildContext context) {
    int maxAmount = 10;

    int supplyAmount = supplyInfo.details['supplyStatus'];
    int limitAmount = supplyInfo.limit['supplyStatus'];

    double supplyPercentage = supplyAmount / maxAmount;
    double limitPercentage = limitAmount / maxAmount;

    DateTime? givenDateTime =
        DateTime.parse(supplyInfo.details['supplyChangeDate']);

    // 'yyyy-MM-dd' 형식으로 날짜를 포맷
    String? formattedDate = DateFormat("yyyy-MM-dd").format(givenDateTime);

    // 현재 날짜와의 차이 계산
    DateTime currentDate = DateTime.now();
    Duration? difference = currentDate.difference(givenDateTime);

    String changedDateString =
        '최근 교체 날짜 : $formattedDate (${difference.inDays}일 경과)';

    bool isDurationOver =
        difference.inDays >= supplyInfo.limit['supplyChangeDate']
            ? true
            : false;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(supplyInfo.name),
                Text('포화도: $supplyAmount/10'),
              ],
            ),
          ),
          // 포화정도 막대바
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SizedBox(
              height: 40,
              width: 300,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      height: 20,
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 219, 219, 219),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: supplyPercentage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: supplyAmount < limitAmount
                                    ? Colors.lightGreen[500]
                                    : Colors.red[400],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(10.0),
                                  bottomLeft: const Radius.circular(10.0),
                                  topRight: Radius.circular(
                                      supplyPercentage == 1 ? 10.0 : 0.0),
                                  bottomRight: Radius.circular(
                                      supplyPercentage == 1 ? 10.0 : 0.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 300 * limitPercentage,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      height: 30,
                      color: Colors.black,
                    ),
                  ),
                  Positioned(
                    left: (300 * limitPercentage) + 5,
                    top: 0,
                    child: Text(
                      '$limitAmount',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              height: 20,
              child: Text(
                changedDateString,
                style: TextStyle(
                    fontSize: 14,
                    color: isDurationOver ? Colors.red : Colors.black),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  buttonMinWidth: 130,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Add functionality to edit notification criteria button
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                      ),
                      child: const Text(
                        '알림 기준 수정',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add functionality to purchase consumables button
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    minimumSize: const Size(260, 40),
                  ),
                  child: Text(
                    '${supplyInfo.name} 구매하러 가기',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 보유량 변경 api 요청 함수
  Future<void> _changeSupplyAmount(BuildContext context, int amount,
      String deviceId, String supplyId) async {
    print("함수");
    var bodyData = jsonEncode({
      "supplyAmount": amount,
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

      http.Response response = await http.patch(
        Uri.parse('${serverUrl}supplies/$supplyId'),
        headers: headers,
        body: bodyData,
      );

      if (response.statusCode == 200) {
        // Map<String, dynamic> responseData =
        //     jsonDecode(utf8.decode(response.bodyBytes));
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('보유량이 수정되었습니다.'),
            actions: [
              TextButton(
                onPressed: () =>
                    // deviceDetailScreen으로 이동하는 코드
                    Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DeviceDetailScreen(deviceId: deviceId),
                  ),
                ),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      } else {
        print('Failed to fetch location data: ${response.statusCode}');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('보유량 수정에 실패했습니다.'),
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

  // 보유량 변경 다이얼로그
  void _showSupplyAmountChangeDialog(BuildContext context) {
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${supplyInfo.name} 보유량 변경',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
          ),
          content: TextFormField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // 숫자만 입력 허용
            ],
            decoration: const InputDecoration(
              hintText: '변경할 보유량을 입력하세요',
              suffixText: 'ml',
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                String newValue = _controller.text;
                // 보유량 변경 api 호출
                await _changeSupplyAmount(
                    context, int.parse(newValue), deviceId, supplyInfo.username);

                if (supplyInfo.details['supplyAmount'] < int.parse(newValue)) {
                  await setMaxAmount(supplyInfo.username, newValue as int);
                }
                print('변경된 값: $newValue');
              },
              child: const Text('변경'),
            ),
          ],
        );
      },
    );
  }
}
