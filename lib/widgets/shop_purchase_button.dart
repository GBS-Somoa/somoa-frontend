import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopPurchaseButton extends StatelessWidget {
  final String shopName;
  final String url;

  const ShopPurchaseButton({
    super.key,
    required this.shopName,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              launchUrl(
                Uri.parse(url),
                mode: LaunchMode.inAppBrowserView,
              );
            },
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(const Size(300, 50)),
              backgroundColor:
                  MaterialStateProperty.all(const Color(0xFFE9E9EB)),
            ),
            child: RichText(
                text: TextSpan(
                    children: [
                  TextSpan(
                      text: shopName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: '에서 구매'),
                ],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ))),
          ),
        ],
      ),
    );
  }
}
