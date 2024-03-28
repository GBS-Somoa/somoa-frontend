import 'package:flutter/material.dart';

class ConfirmWidget extends StatelessWidget {

  final String title;
  final String text;
  final VoidCallback onYes;
  final String yesText;
  final String noText;

  ConfirmWidget({
    required this.title,
    required this.text,
    required this.onYes,
    this.yesText = '확인',
    this.noText = '취소',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10), // Add horizontal padding
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 0), // Add inner padding
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20), // Optional: if you want rounded corners
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              text,
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: Text(noText, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.pop(context),
                ),
                Container(
                  height: 30,
                  child: VerticalDivider(color: Colors.black54),
                ),
                TextButton(
                  child: Text(yesText, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    onYes(); // 확인 버튼의 동작을 호출합니다.
                    Navigator.pop(context); // 모달을 닫습니다.
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
