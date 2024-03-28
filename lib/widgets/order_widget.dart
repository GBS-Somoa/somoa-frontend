import 'package:flutter/material.dart';

class OrderWidget extends StatelessWidget {
  final Map<String, Object> orderInfo;

  OrderWidget({
    super.key,
    required this.orderInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    // 텍스트를 먼저 배치
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            orderInfo['orderStore'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            orderInfo['productName'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // 이미지를 오른쪽에 배치
                    Container(
                      width: 70, // 이미지의 너비
                      height: 70, // 이미지의 높이
                      child: Image.network(
                        orderInfo['productImg'] as String,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                // 배송 상태 표시하는 위젯은 이전과 같이 배치
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Image.asset(
                    orderInfo['orderStatus'] == '결제완료'
                        ? 'assets/images/deliveryStatus=onlyPurchase.png'
                        : orderInfo['orderStatus'] == '배송시작'
                        ? 'assets/images/deliveryStatus=deliveryStart.png'
                        : orderInfo['orderStatus'] == '배송중'
                        ? 'assets/images/deliveryStatus=deliveryIng.png'
                        : 'assets/images/deliveryStatus=deliveryStart.png',
                    width: 150,
                  ),
                ),
                // 쇼핑몰로 이동하는 버튼은 이전과 같이 배치
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to shopping mall
                      },
                      child: Text(
                        '쇼핑몰로 이동',
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 12, color: Color.fromARGB(255, 23, 82, 134))
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
