import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:somoa/providers/user_provider.dart';
import 'package:somoa/widgets/list_container_widget.dart';
import 'package:somoa/widgets/order_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class Order {
  final int orderId;
  final String groupName;
  final String orderStatus;
  final String productName;
  final String orderStore;
  final int orderStoreId;
  final String productImg;
  final String deviceName;

  Order({
    required this.orderId,
    required this.groupName,
    required this.orderStatus,
    required this.productName,
    required this.orderStore,
    required this.orderStoreId,
    required this.productImg,
    required this.deviceName,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] as int,
      groupName: json['groupName'] as String,
      orderStatus: json['orderStatus'] as String,
      productName: json['productName'] as String,
      orderStore: json['orderStore'] as String,
      orderStoreId: json['orderStoreId'] as int,
      productImg: json['productImg'] as String,
      deviceName: json['deviceName'] as String,
    );
  }
}

class _ProfileScreenState extends State<ProfileScreen> {

  static const storage = FlutterSecureStorage();
  List<Order> orders = [
    Order(
      orderId: 0,
      groupName: '우리집',
      orderStatus: '배송완료',
      productName: '다우니 세제 1L',
      orderStore: 'SSAPANG',
      orderStoreId: 0,
      productImg: 'https://img.danawa.com/prod_img/500000/437/683/img/13683437_1.jpg?_v=20210323145912',
      deviceName: '세탁기',
    ),
    Order(
      orderId: 1,
      groupName: '너네집',
      orderStatus: '결제완료',
      productName: '다우니 세제 1L',
      orderStore: 'SSAPANG',
      orderStoreId: 0,
      productImg: 'https://img.danawa.com/prod_img/500000/437/683/img/13683437_1.jpg?_v=20210323145912',
      deviceName: '세탁기',
    ),
    Order(
      orderId: 2,
      groupName: '내집',
      orderStatus: '결제완료',
      productName: '어쩌구저쩌구 정품 필터 이름이 되게되게 길어서 ...으ㅕ로 나오는지 확인해보기 위한 테스트용 상품 이름',
      orderStore: '삼성몰',
      orderStoreId: 1,
      productImg: 'https://img.danawa.com/prod_img/500000/437/683/img/13683437_1.jpg?_v=20210323145912',
      deviceName: '공기청정기',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // fetchData();
  }

  Future<void> fetchData() async {
    await getOrderList();
  }

  Future<void> getOrderList() async {
    final accessToken = await storage.read(key: 'accessToken');

    String serverUrl = dotenv.get("SERVER_URL");
    final url = Uri.parse('$serverUrl' 'user/orders');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);

        if (data['data'] != null) {
          final List<dynamic> ordersJson = data['data'];
          setState(() {
            orders = ordersJson.map((order) => Order.fromJson(order)).toList();
          });
        }
      } else {
        print(response.body);
        print(response.statusCode);
        print('내가 주문한 주문목록 조회 실패');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Map<String, Object> makeOrderInfo(Order order) {
    return {
      'orderStore': order.orderStore,
      'productName': order.productName,
      'productImg': order.productImg,
      'orderStatus': order.orderStatus,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                userProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          '${userProvider.nickname}',
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        Text('${userProvider.username}')
                      ],
                    ),
                  ),
                ),
                ListContainerWidget(
                    children: [
                      ListTile(
                        title: Text('프로필 관리'),
                        onTap: () {
                          print('Item 1 tapped');
                        },
                      ),
                      ListTile(
                        title: Text('장소 관리'),
                        onTap: () {
                          print('Item 2 tapped');
                          Navigator.pushNamed(context, '/locationList');
                        },
                      ),
                      ListTile(
                        title: Text('즐겨찾는 쇼핑몰 관리'),
                        onTap: () {
                          print('Item 3 tapped');
                        },
                      ),
                    ]
                ),
                SizedBox(height: 20),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '      진행중인 배송',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          if (order.orderStatus != '주문취소') {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0), // 왼쪽에 20 픽셀의 패딩 추가
                                    child: Text(
                                      '${order.groupName} > ${order.deviceName}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  OrderWidget(orderInfo: makeOrderInfo(order)),
                                ],
                              ),
                            );
                          } else {
                            return SizedBox(); // 주문 취소인 경우 아무 것도 렌더링하지 않음
                          }
                        },
                      ),
                    ])
              ],
            ),
          ),
        ),
      );
    });
  }
}
