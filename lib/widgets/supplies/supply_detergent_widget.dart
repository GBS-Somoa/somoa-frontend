import 'package:flutter/material.dart';

class SupplyDetergentWidget extends StatelessWidget {
  final Supply supply;

  SupplyDetergentWidget({required this.supply});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(supply.name),
        LinearProgressIndicator(
          value: supply.detail['supplyAmount'] / supply.limit['supplyAmount'],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                // Handle supply amount change
              },
              child: Text('보유량 변경'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to order screen
              },
              child: Text('주문하러가기'),
            ),
          ],
        ),
      ],
    );
  }
}

class Supply {
  final String name;
  final Map<String, dynamic> detail;
  final Map<String, dynamic> limit;

  Supply({
    required this.name,
    required this.detail,
    required this.limit,
  });
}
