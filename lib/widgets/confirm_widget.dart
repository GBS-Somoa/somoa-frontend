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
      padding: EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.fromLTRB(25, 20, 25, 0),
        height: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
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
                    onYes();
                    Navigator.pop(context);
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
