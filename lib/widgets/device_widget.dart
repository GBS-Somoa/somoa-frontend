import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:somoa/screens/device/device_detail_screen.dart';
import 'package:somoa/widgets/water_saturation_widget.dart';

class DeviceWidget extends StatelessWidget {
  final dynamic deviceInfo;

  const DeviceWidget({
    super.key,
    required this.deviceInfo,
  });

  transformDate(String date) {
    return DateFormat('yyyy-MM-dd').format(DateTime.parse(date));
  }

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
                  deviceInfo.nickname,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                    onPressed: () {
                      // deviceDetailScreen으로 이동하는 코드
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DeviceDetailScreen(deviceId: deviceInfo.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.navigate_next, size: 35))
              ],
            ),
            const SizedBox(height: 8),
            Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: deviceInfo.supplies.isNotEmpty
                    ? _buildSupplyList(deviceInfo.supplies)
                    : const [
                        Text(
                          '소모품 정보 없음',
                          style: TextStyle(fontSize: 16),
                        ),
                      ]),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSupplyList(List<dynamic> supplies) {
    List<Widget> supplyWidgets = [];
    for (var supply in supplies) {
      String supplyType = supply.type;
      Widget supplyInfoWidget;

      if (['washerDetergent', 'fabricSoftener', 'dishDetergent', 'dishRinse']
          .contains(supplyType)) {
        supplyInfoWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${supply.name}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('현재 보유량'),
                Text(
                  '${supply.details['supplyAmount']} ml',
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
              '${supply.name}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('최근 교체 날짜'),
                  Text(transformDate(supply.details['supplyChangeDate']),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              if (supply.details['supplyLevel']
                  is int) // Check if supplyAmount is an integer
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: WaterSaturationWidget(
                      level: supply.details['supplyLevel']),
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
              '${supply.name}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('최근 교체 날짜'),
                  Text(transformDate(supply.details['supplyChangeDate']),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    const Text('필터 상태'),
                    const SizedBox(height: 5),
                    Image.asset(
                      'assets/images/face=${supply.details['supplyStatus']}.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 8),
          ],
        );
      } else if (supplyType == 'dustBin') {
        // Handle other supply types here
        supplyInfoWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${supply.name}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('최근 교체 날짜'),
                  Text(transformDate(supply.details['supplyChangeDate']),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    const Text(
                      '포화 정도',
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      '${supply.details['supplyStatus']} / 10',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 8),
          ],
        );
      } else {
        supplyInfoWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${supply.name}',
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
