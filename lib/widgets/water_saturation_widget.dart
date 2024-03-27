import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class WaterSaturationWidget extends StatelessWidget {
  final int amount;

  const WaterSaturationWidget({
    super.key,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: LiquidCircularProgressIndicator(
        value: amount / 100, // 0에서 1 사이의 값
        valueColor: const AlwaysStoppedAnimation(Colors.blue), // 프로그레스 색상
        backgroundColor: Colors.white, // 배경 색상
        borderColor: Colors.blue,
        borderWidth: 3.0,
        direction: Axis.vertical, // 액체 움직임 방향
        center: Text('$amount%'), // 중앙에 표시될 위젯
      ),
    );
  }
}
