import 'package:flutter/material.dart';
import 'package:somoa/screens/order/recent_order.dart';
import 'package:somoa/services/api_services.dart';
import 'package:somoa/widgets/menu_bar_widget.dart';
import 'package:somoa/widgets/shop_purchase_button.dart';
import 'package:url_launcher/url_launcher.dart';

// deviceModel, supplyType, supplyId, manufacture를 받아서 supplyId를 기반으로 최근 주문내역 조회요청을 보내고 응답이 있으면 해당 응답으로부터 productName, productImg(url)를 받아서 상단에 렌더링하고, 아래쪽에는 SSAG에서 구매, SSAPANG에서 구매, 공식몰에서 구매 버튼을 렌더링하는 OrderConnectionScreen
// 쇼핑몰 구매 링크에는 userId={username}, groupId, supplyId, keyword={검색어}를 포함
// 검색어 : 세제류는 소모품명으로, 필터 등은 기기 모델 + 소모품명

class OrderConnectionScreen extends StatefulWidget {
  final String deviceModel;
  final String supplyType;
  final String supplyId;
  final String manufacture;
  final String username;
  final String groupId;

  const OrderConnectionScreen({
    super.key,
    required this.deviceModel,
    required this.supplyType,
    required this.supplyId,
    required this.manufacture,
    required this.username,
    required this.groupId,
  });

  @override
  _OrderConnectionScreenState createState() => _OrderConnectionScreenState();
}

class _OrderConnectionScreenState extends State<OrderConnectionScreen> {
  late Future<List<RecentOrder>> recentOrder;

  @override
  void initState() {
    super.initState();
    recentOrder = getRecentOrder(widget.supplyId);
  }

  @override
  Widget build(BuildContext context) {
    bool isLiquid = [
      "washerDetergent",
      "fabricSoftener",
      "dishDetergent",
      "dishRinse"
    ].contains(widget.supplyType);

    Map<String, String> title = {
      "washerDetergent": "세탁세제",
      "fabricSoftener": "섬유유연제",
      "dishDetergent": "식기세척기 세제",
      "dishRinse": "식기세척기 린스",
      "cleanableFilter": "청소형 필터",
      "replaceableFilter": "교체형 필터",
      "supplyTank": "급수통",
      "drainTank": "배수통",
      "dustBin": "먼지통",
    };

    return Scaffold(
      appBar: MenuBarWidget(
        titleText: title[widget.supplyType] ?? "소모품",
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder(
              future: recentOrder,
              builder: (context, snapshot) {
                if (snapshot.hasData == false) {
                  // data 로딩 중
                  return const Text("최근 구매한 제품을 불러오는 중입니다.");
                } else if (snapshot.hasError) {
                  // 에러
                  print("에러: ${snapshot.error}");
                  return const Text("최근 구매한 제품을 불러오지 못했습니다.");
                } else {
                  // 성공
                  List<RecentOrder>? rol = snapshot.data;
                  if (rol != null && rol.isNotEmpty) {
                    return recentPurchase(
                        rol[0], widget.username, widget.groupId);
                  } else {
                    return const Text("최근 구매한 제품이 없습니다.");
                  }
                }
              },
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ShopPurchaseButton(
            shopName: "SSAG",
            // 여기서 url 만들어서 넘기면 됨
            url: widget.supplyType == "cleanableFilter" ||
                    widget.supplyType == "replaceableFilter"
                ? "https://shop.somoa.net/products?user_id=${widget.username}&group_id=${widget.groupId}&supply_id=${widget.supplyId}&keyword=${widget.deviceModel}"
                : "https://shop.somoa.net/products?user_id=${widget.username}&group_id=${widget.groupId}&supply_id=${widget.supplyId}&keyword=${title[widget.supplyType]}",
          ),
          const ShopPurchaseButton(
            shopName: "SSAPANG",
            url: "https://shop.somoa.net/products",
          ),
          if (!isLiquid)
            const ShopPurchaseButton(
              shopName: "공식몰",
              url:
                  "https://www.samsungsvc.co.kr/shop/product?category=10422&directory=10553&option=10555",
            ),
        ],
      ),
    );
  }
}

Widget recentPurchase(
    RecentOrder recentOrder, String username, String groupId) {
  return Column(
    children: [
      const Text(
        "최근 구매한 제품",
        style: TextStyle(fontSize: 20),
      ),
      const SizedBox(height: 10),
      Image.network(
        recentOrder.productImg,
        height: 200,
        width: 200,
      ),
      const SizedBox(height: 10),
      Text(
        recentOrder.productName,
        style: const TextStyle(
          fontSize: 15,
        ),
      ),
      const SizedBox(height: 10),
      ElevatedButton(
        onPressed: () {
          launchUrl(
            Uri.parse('https://shop.somoa.net/products'
                '?user_id=${username}&group_id=${groupId}&supply_id=${recentOrder.supplyId}&keyword=${recentOrder.productName}'),
            mode: LaunchMode.inAppBrowserView,
          );
        },
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size(300, 50)),
        ),
        child: const Text(
          '같은 제품 재구매하기',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
    ],
  );
}
