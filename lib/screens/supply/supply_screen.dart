import 'package:flutter/material.dart';
import 'package:somoa/utils/bottom_navigation_bar.dart';

class SupplyScreen extends StatefulWidget {
  const SupplyScreen({super.key});

  @override
  _SupplyScreenState createState() => _SupplyScreenState();
}

class _SupplyScreenState extends State<SupplyScreen> {
  // 교체가 필요한 소모품 목록, 충전이 필요한 소모품 목록, 청소가 필요한 소모품 목록
  // TODO: user가 포함된 장소 목록 가져오고(전역에 저장), 장소 돌면서 (장소id, 조건)에 해당하는 소모품 목록 가져와서 append

  // 임시 데이터
  List<Object> supplyNeedClean = [];
  List<Object> supplyNeedCharge = [];
  List<Object> supplyNeedReplace = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          // Add your widget tree here
          ),
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 1,
      ),
    );
  }
}
