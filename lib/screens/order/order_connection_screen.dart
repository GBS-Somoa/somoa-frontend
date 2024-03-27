import 'package:flutter/material.dart';

// deviceModel, supplyType, supplyId, manufacture를 받아서 supplyId를 기반으로 최근 주문내역 조회요청을 보내고 응답이 있으면 해당 응답으로부터 productName, productImg(url)를 받아서 상단에 렌더링하고, 아래쪽에는 SSAG에서 구매, SSAPANG에서 구매, 공식몰에서 구매 버튼을 렌더링하는 OrderConnectionScreen

class OrderConnectionScreen extends StatefulWidget {
  final String deviceModel;
  final String supplyType;
  final String supplyId;
  final String manufacture;

  OrderConnectionScreen({
    required this.deviceModel,
    required this.supplyType,
    required this.supplyId,
    required this.manufacture,
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
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        // Update the productName and productImgUrl with the received response data
        productName = 'Example Product';
        productImgUrl = 'https://example.com/product-image.jpg';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Connection'),
      ),
      body: Column(
        children: [
          // Render the productName and productImgUrl at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  productName,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                Image.network(
                  productImgUrl,
                  height: 200,
                  width: 200,
                ),
              ],
            ),
          ),
          // Render the buttons for purchasing from different sources
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Handle SSAG purchase button click
                },
                child: Text('SSAG에서 구매'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle SSAPANG purchase button click
                },
                child: Text('SSAPANG에서 구매'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle 공식몰 purchase button click
                },
                child: Text('공식몰에서 구매'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
