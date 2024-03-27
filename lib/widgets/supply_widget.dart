import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SupplyWidget extends StatelessWidget {
  final Map<String, Object> supplyInfo;

  const SupplyWidget({super.key, required this.supplyInfo});

  @override
  Widget build(BuildContext context) {
    switch (supplyInfo['type']) {
      case 'washerDetergent':
      case 'fabricSoftener':
      case 'dishDetergent':
      case 'dishRinse':
        return _buildDetergentCard();
      case 'cleanableFilter':
      case 'replaceableFilter':
        return _buildFilterCard();
      case 'supplyTank':
      case 'drainTank':
        return _buildTankCard();
      case 'dustBin':
        return _buildDustBinCard();
      default:
        return const SizedBox();
    }
  }

  Widget _buildDetergentCard() {
    // TODO: 기기 내부에 저장된 데이터에서 supplyId에 맞는 maxAmount를 가져오도록 작성해야함
    int maxAmount = 1000;

    int supplyAmount = (supplyInfo['details'] as Map)['supplyAmount'];
    int limitAmount = (supplyInfo['limit'] as Map)['supplyAmount'];

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
                Text(supplyInfo['name'].toString()),
                Text('${supplyAmount}ml'),
              ],
            ),
          ),
          // 보유량 막대바 -> AmountTmp 추가해야함(TODO)
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
                        // Add functionality to edit inventory button
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
                    '${supplyInfo['name']} 구매하러 가기',
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

  Widget _buildFilterCard() {
    final String supplyStatus =
        (supplyInfo['details'] as Map)['supplyStatus'].toString().toLowerCase();
    final String limitStatus =
        (supplyInfo['limit'] as Map)['supplyStatus'].toString().toLowerCase();

    double maxAmount = 1.0;

    double supplyAmount = supplyStatus == 'bad'
        ? 0.33
        : supplyStatus == 'normal'
            ? 0.66
            : supplyStatus == 'good'
                ? 1.0
                : 0.0;

    double limitAmount = limitStatus == 'bad'
        ? 0.33
        : limitStatus == 'normal'
            ? 0.66
            : limitStatus == 'good'
                ? 1.0
                : 0.0;

    double supplyPercentage = supplyAmount / maxAmount;
    double limitPercentage = limitAmount / maxAmount;

    DateTime? givenDateTime =
        DateTime.parse((supplyInfo['details'] as Map)['supplyChangeDate']);

    // 'yyyy-MM-dd' 형식으로 날짜를 포맷
    String? formattedDate = DateFormat("yyyy-MM-dd").format(givenDateTime);

    // 현재 날짜와의 차이 계산
    DateTime currentDate = DateTime.now();
    Duration? difference = currentDate.difference(givenDateTime);

    String changedDateString = supplyInfo['type'] == 'cleanableFilter'
        ? '최근 청소 날짜 : $formattedDate (${difference.inDays}일 경과)'
        : '최근 교체 날짜 : $formattedDate (${difference.inDays}일 경과)';

    bool isDurationOver =
        difference.inDays >= (supplyInfo['limit'] as Map)['supplyChangeDate']
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
                Text(supplyInfo['name'].toString()),
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
                supplyInfo['type'] == 'cleanableFilter'
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
                          '${supplyInfo['name']} 구매하러 가기',
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

  Widget _buildTankCard() {
    int maxAmount = 100;

    int supplyAmount = (supplyInfo['details'] as Map)['supplyLevel'];
    int limitAmount = (supplyInfo['limit'] as Map)['supplyLevel'];

    double supplyPercentage = supplyAmount / maxAmount;
    double limitPercentage = limitAmount / maxAmount;

    DateTime? givenDateTime =
        DateTime.parse((supplyInfo['details'] as Map)['supplyChangeDate']);

    // 'yyyy-MM-dd' 형식으로 날짜를 포맷
    String? formattedDate = DateFormat("yyyy-MM-dd").format(givenDateTime);

    // 현재 날짜와의 차이 계산
    DateTime currentDate = DateTime.now();
    Duration? difference = currentDate.difference(givenDateTime);

    String changedDateString =
        '최근 교체 날짜 : $formattedDate (${difference.inDays}일 경과)';

    bool isDurationOver =
        difference.inDays >= (supplyInfo['limit'] as Map)['supplyChangeDate']
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
                Text(supplyInfo['name'].toString()),
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
                                color: supplyInfo['type'] == 'supplyTank'
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

  Widget _buildDustBinCard() {
    int maxAmount = 10;

    int supplyAmount = (supplyInfo['details'] as Map)['supplyStatus'];
    int limitAmount = (supplyInfo['limit'] as Map)['supplyStatus'];

    double supplyPercentage = supplyAmount / maxAmount;
    double limitPercentage = limitAmount / maxAmount;

    DateTime? givenDateTime =
        DateTime.parse((supplyInfo['details'] as Map)['supplyChangeDate']);

    // 'yyyy-MM-dd' 형식으로 날짜를 포맷
    String? formattedDate = DateFormat("yyyy-MM-dd").format(givenDateTime);

    // 현재 날짜와의 차이 계산
    DateTime currentDate = DateTime.now();
    Duration? difference = currentDate.difference(givenDateTime);

    String changedDateString =
        '최근 교체 날짜 : $formattedDate (${difference.inDays}일 경과)';

    bool isDurationOver =
        difference.inDays >= (supplyInfo['limit'] as Map)['supplyChangeDate']
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
                Text(supplyInfo['name'].toString()),
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
                    '${supplyInfo['name']} 구매하러 가기',
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
}
