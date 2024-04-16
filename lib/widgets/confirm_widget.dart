import 'package:flutter/material.dart';

class ConfirmWidget extends StatelessWidget {

  final String title;
  final String text;
  final VoidCallback onYes;
  final Text yesText;
  final Text noText;
  final double height;

  ConfirmWidget({
    required this.title,
    required this.text,
    required this.onYes,
    required this.height,
    this.yesText = const Text('확인', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    this.noText = const Text('취소', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
      ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 여기를 수정했습니다.
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              text,
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.start,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  child: noText,
                  onPressed: () => Navigator.pop(context),
                ),
                Container(
                  height: 30,
                  child: VerticalDivider(color: Colors.black54),
                ),
                TextButton(
                  child: yesText,
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
