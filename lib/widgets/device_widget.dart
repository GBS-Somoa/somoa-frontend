import 'package:flutter/material.dart';
import 'package:somoa/widgets/water_saturation_widget.dart';

class DeviceWidget extends StatelessWidget {
  final Map<String, dynamic> deviceInfo;

  const DeviceWidget({
    super.key,
    required this.deviceInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  deviceInfo['deviceNickname'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.navigate_next, size: 35)
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildSupplyList(deviceInfo['supplies']),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSupplyList(List<dynamic> supplies) {
    List<Widget> supplyWidgets = [];
    for (var supply in supplies) {
      String supplyType = supply['supplyType'];
      Widget supplyInfoWidget;

      if (supplyType == 'washerDetergent' || supplyType == 'fabricSoftener') {
        supplyInfoWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${supply['supplyName']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('현재 보유량'),
                Text(
                  '${supply['supplyAmount']} ml',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        );
      } else if (supplyType == 'supplyTank' || supplyType == 'drainTank') {
        supplyInfoWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${supply['supplyName']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('최근 교체 날짜'),
                  Text('${supply['supplyChangeDate']}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              if (supply['supplyAmount']
                  is int) // Check if supplyAmount is an integer
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: WaterSaturationWidget(amount: supply['supplyAmount']),
                ),
            ])
          ],
        );
      } else if (supplyType == 'cleanableFilter' ||
          supplyType == 'replaceableFilter') {
        supplyInfoWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${supply['supplyName']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '상태: ${supply['supplyStatus'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${supplyType == 'cleanableFilter' ? '최근 청소 날짜' : '최근 교체 날짜'}: ${supply['supplyChangeDate']}',
                  style: const TextStyle(fontSize: 14),
                )
              ],
            ),
            const SizedBox(height: 8),
          ],
        );
      } else if (supplyType == 'dustBin') {
        // Handle other supply types here
        supplyInfoWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${supply['supplyName']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '포화정도: ${supply['supplyAmount']}/10',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
          ],
        );
      } else {
        supplyInfoWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${supply['supplyName']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              '소모품 형식에 문제 있음',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
          ],
        );
      }

      supplyWidgets.add(
        Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 5),
          color: Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: supplyInfoWidget,
          ),
        ),
      );
    }
    return supplyWidgets;
  }
}
