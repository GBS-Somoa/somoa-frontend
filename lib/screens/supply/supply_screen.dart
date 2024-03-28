import 'package:flutter/material.dart';
import 'package:somoa/widgets/menu_bar_widget.dart';

class SupplyScreen extends StatefulWidget {
  const SupplyScreen({super.key});

  @override
  _SupplyScreenState createState() => _SupplyScreenState();
}

class _SupplyScreenState extends State<SupplyScreen> {
  // 교체가 필요한 소모품 목록, 충전이 필요한 소모품 목록, 청소가 필요한 소모품 목록
  // TODO: user가 포함된 장소 목록 가져오고(전역에 저장), 장소 돌면서 (장소id, 조건)에 해당하는 소모품 목록 가져와서 append

  Map<String, dynamic> data = {
    "isCareNeeded": {
      "charge": [
        {
          "supplyLimit": {"supplyAmount": 0},
          "supplyName": "세제",
          "groupName": "Group 1",
          "supplyId": "6604ff5879b7926a685f879c",
          "supplyType": "washerDetergent",
          "groupId": 1,
          "supplyDetails": {"supplyAmount": 0},
          "supplyAmountTmp": 0,
          "deviceId": "245d1d553e2acd72",
          "deviceNickname": "dddd"
        },
        {
          "supplyLimit": {"supplyAmount": 0},
          "supplyName": "섬유유연제",
          "groupName": "Group 1",
          "supplyId": "6604ff5879b7926a685f879b",
          "supplyType": "fabricSoftener",
          "groupId": 1,
          "supplyDetails": {"supplyAmount": 0},
          "supplyAmountTmp": 0,
          "deviceId": "245d1d553e2acd72",
          "deviceNickname": "dddd"
        },
        {
          "supplyLimit": {"supplyAmount": 0},
          "supplyName": "a",
          "groupName": "Group 3",
          "supplyId": "6604ff5a79b7926a685f87aa",
          "supplyType": "fabricSoftener",
          "groupId": 3,
          "supplyDetails": {"supplyAmount": 0},
          "supplyAmountTmp": 0,
          "deviceId": "e93872ca1f6e3e27",
          "deviceNickname": "dddd"
        },
        {
          "supplyLimit": {"supplyAmount": 0},
          "supplyName": "c",
          "groupName": "Group 3",
          "supplyId": "6604ff5a79b7926a685f87ab",
          "supplyType": "dishDetergent",
          "groupId": 3,
          "supplyDetails": {"supplyAmount": 0},
          "supplyAmountTmp": 0,
          "deviceId": "e93872ca1f6e3e27",
          "deviceNickname": "dddd"
        },
        {
          "supplyLimit": {"supplyAmount": 0},
          "supplyName": "e",
          "groupName": "Group 3",
          "supplyId": "6604ff5a79b7926a685f87ac",
          "supplyType": "washerDetergent",
          "groupId": 3,
          "supplyDetails": {"supplyAmount": 0},
          "supplyAmountTmp": 0,
          "deviceId": "e93872ca1f6e3e27",
          "deviceNickname": "dddd"
        }
      ],
      "replace": [
        {
          "supplyLimit": {"supplyChangeDate": 365, "supplyStatus": "bad"},
          "supplyName": "교체필터",
          "groupName": "Group 1",
          "supplyId": "6604ff5979b7926a685f87a2",
          "supplyType": "replaceableFilter",
          "groupId": 1,
          "supplyDetails": {
            "supplyChangeDate": "2024-03-28T05:25:45.406+00:00",
            "supplyStatus": "good"
          },
          "deviceId": "5e04bd56dfcf7ca0",
          "deviceNickname": "dddd"
        },
        {
          "supplyLimit": {"supplyChangeDate": 365, "supplyStatus": "bad"},
          "supplyName": "b",
          "groupName": "Group 3",
          "supplyId": "6604ff5a79b7926a685f87a5",
          "supplyType": "replaceableFilter",
          "groupId": 3,
          "supplyDetails": {
            "supplyChangeDate": "2024-03-28T05:25:46.229+00:00",
            "supplyStatus": "good"
          },
          "deviceId": "e93872ca1f6e3e27",
          "deviceNickname": "dddd"
        }
      ],
      "clean": [
        {
          "supplyLimit": {"supplyStatus": 8},
          "supplyName": "먼지봉투",
          "groupName": "Group 1",
          "supplyId": "6604ff5979b7926a685f87a1",
          "supplyType": "dustBin",
          "groupId": 1,
          "supplyDetails": {"supplyStatus": 10},
          "deviceId": "5e04bd56dfcf7ca0",
          "deviceNickname": "dddd"
        },
        {
          "supplyLimit": {"supplyChangeDate": 365, "supplyStatus": "bad"},
          "supplyName": "d",
          "groupName": "Group 3",
          "supplyId": "6604ff5a79b7926a685f87a6",
          "supplyType": "cleanableFilter",
          "groupId": 3,
          "supplyDetails": {
            "supplyChangeDate": "2024-03-28T05:25:46.232+00:00",
            "supplyStatus": "good"
          },
          "deviceId": "e93872ca1f6e3e27",
          "deviceNickname": "dddd"
        },
        {
          "supplyLimit": {"supplyStatus": 8},
          "supplyName": "i",
          "groupName": "Group 3",
          "supplyId": "6604ff5a79b7926a685f87a9",
          "supplyType": "dustBin",
          "groupId": 3,
          "supplyDetails": {"supplyStatus": 10},
          "deviceId": "e93872ca1f6e3e27",
          "deviceNickname": "dddd"
        },
        {
          "supplyLimit": {"supplyStatus": 8},
          "supplyName": "봉투",
          "groupName": "Group 1",
          "supplyId": "6604ff5879b7926a685f879f",
          "supplyType": "dustBin",
          "groupId": 1,
          "supplyDetails": {"supplyStatus": 10},
          "deviceId": "d78e935afc4a34b5",
          "deviceNickname": "dddd"
        }
      ]
    },
    "totalCount": 19,
    "isCareNotNeeded": {
      "charge": [
        {
          "supplyLimit": {"supplyLevel": 10},
          "supplyName": "서플탱크",
          "groupName": "Group 1",
          "supplyId": "6604ff5979b7926a685f87a3",
          "supplyType": "supplyTank",
          "groupId": 1,
          "supplyDetails": {"supplyLevel": 0},
          "deviceId": "c21ba6879d8af9f7",
          "deviceNickname": "dddd"
        },
        {
          "supplyLimit": {"supplyLevel": 10},
          "supplyName": "g",
          "groupName": "Group 3",
          "supplyId": "6604ff5a79b7926a685f87a7",
          "supplyType": "supplyTank",
          "groupId": 3,
          "supplyDetails": {"supplyLevel": 0},
          "deviceId": "e93872ca1f6e3e27",
          "deviceNickname": "dddd"
        },
        {
          "supplyLimit": {"supplyLevel": 10},
          "supplyName": "물품탱크",
          "groupName": "Group 1",
          "supplyId": "6604ff5879b7926a685f879e",
          "supplyType": "supplyTank",
          "groupId": 1,
          "supplyDetails": {"supplyLevel": 0},
          "deviceId": "d78e935afc4a34b5",
          "deviceNickname": "dddd"
        }
      ],
      "replace": [],
      "clean": [
        {
          "supplyLimit": {"supplyLevel": 90},
          "supplyName": "흡수탱크",
          "groupName": "Group 1",
          "supplyId": "6604ff5979b7926a685f87a0",
          "supplyType": "drainTank",
          "groupId": 1,
          "supplyDetails": {"supplyLevel": 100},
          "deviceId": "5e04bd56dfcf7ca0",
          "deviceNickname": "dddd"
        },
        {
          "supplyLimit": {"supplyLevel": 90},
          "supplyName": "h",
          "groupName": "Group 3",
          "supplyId": "6604ff5a79b7926a685f87a8",
          "supplyType": "drainTank",
          "groupId": 3,
          "supplyDetails": {"supplyLevel": 100},
          "deviceId": "e93872ca1f6e3e27",
          "deviceNickname": "dddd"
        }
      ]
    }
  };

  // 임시 데이터
  List<Object> supplyNeedClean = [];
  List<Object> supplyNeedCharge = [];
  List<Object> supplyNeedReplace = [];

  @override
  Widget build(BuildContext context) {
    Map<String, List> careNeedSupply = data['isCareNeeded'];
    Map<String, List> careNotNeedSupply = data['isCareNotNeeded'];
    int totalCount = data['totalCount'];

    Map careNeedCount = {};
    Map careNotNeedCount = {};
    int careNeedTotal = 0;
    int careNotNeedTotal = 0;

    careNeedSupply.forEach((key, value) {
      careNeedCount[key] = value.length;
      careNeedTotal += value.length;
    });

    careNotNeedSupply.forEach((key, value) {
      careNotNeedCount[key] = value.length;
      careNotNeedTotal += value.length;
    });

    return Scaffold(
      appBar: const MenuBarWidget(
          titleText: '소모품 상태 모아보기', appBarHeight: 85.0, topPadding: 0.0),
      body: Container(
        child: Column(children: [
          Center(
            child: Image.asset(
                'assets/images/face=${careNeedTotal == 0 ? "good" : careNeedTotal > careNotNeedTotal ? "normal" : "bad"}.png',
                height: 150),
          ),
        ]),
      ),
    );
  }
}

class SupplyItem {
  final String supplyName;
  final String groupName;
  final String supplyId;
  final String supplyType;
  final int groupId;
  final Map<String, dynamic> supplyDetails;
  final Map<String, dynamic> supplyLimit;
  final String deviceId;
  final String deviceNickname;

  SupplyItem({
    required this.supplyLimit,
    required this.supplyName,
    required this.groupName,
    required this.supplyId,
    required this.supplyType,
    required this.groupId,
    required this.supplyDetails,
    required this.deviceId,
    required this.deviceNickname,
  });

  factory SupplyItem.fromJson(Map<String, dynamic> json) {
    return SupplyItem(
      supplyLimit: json['supplyLimit'],
      supplyName: json['supplyName'],
      groupName: json['groupName'],
      supplyId: json['supplyId'],
      supplyType: json['supplyType'],
      groupId: json['groupId'],
      supplyDetails: json['supplyDetails'],
      deviceId: json['deviceId'],
      deviceNickname: json['deviceNickname'],
    );
  }
}
