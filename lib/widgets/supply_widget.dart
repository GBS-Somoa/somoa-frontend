import 'package:flutter/material.dart';

class SupplyWidget extends StatelessWidget {
  final Map<String, Object> supplyInfo;

  const SupplyWidget({Key? key, required this.supplyInfo}) : super(key: key);

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
        return SizedBox();
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
                              color: Color.fromARGB(255, 219, 219, 219),
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
                      style: TextStyle(
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
    return Card(
      child: ListTile(
        title: Text(supplyInfo['name'].toString()),
        subtitle: Text(supplyInfo['type'].toString()),
        // Add further widget customization as needed
      ),
    );
  }

  Widget _buildTankCard() {
    return Card(
      child: ListTile(
        title: Text(supplyInfo['name'].toString()),
        subtitle: Text(supplyInfo['type'].toString()),
        // Add further widget customization as needed
      ),
    );
  }

  Widget _buildDustBinCard() {
    return Card(
      child: ListTile(
        title: Text(supplyInfo['name'].toString()),
        subtitle: Text(supplyInfo['type'].toString()),
        // Add further widget customization as needed
      ),
    );
  }
}
