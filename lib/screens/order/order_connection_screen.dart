import 'package:flutter/material.dart';
import 'package:somoa/screens/order/recent_order.dart';
import 'package:somoa/widgets/menu_bar_widget.dart';
import 'package:somoa/widgets/shop_purchase_button.dart';

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
  String productName = '';
  String productImgUrl = '';

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  void fetchOrderDetails() {
    // Send request to retrieve recent order details based on supplyId
    // Make an API call or perform any necessary logic here

    // Simulating a response
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        // Update the productName and productImgUrl with the received response data
        productName = 'Example Product';
        productImgUrl = 'https://example.com/product-image.jpg';
      });
    });
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
      "washerDetergent": "세탁 세제",
      "fabricSoftener": "섬유유연제",
      "dishDetergent": "식기세척기 세제",
      "dishRinse": "식기세척기 린스",
      "cleanableFilter": "청소 필터",
      "replaceableFilter": "교체 필터",
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
          const SizedBox(
            height: 20,
          ),
          const ShopPurchaseButton(
            shopName: "SSAG",
            // 여기서 url 만들어서 넘기면 됨
            url: "https://shop.somoa.net/products",
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
