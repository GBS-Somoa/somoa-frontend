import 'package:flutter/material.dart';

class MenuBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final double appBarHeight;
  final double topPadding;
  final String? title;

  const MenuBarWidget({
    super.key,
    required this.titleText,
    this.appBarHeight = 85.0, // AppBar의 높이 기본값
    this.topPadding = 25.0, // 상단 여백 기본값
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: topPadding), // 상단 여백
        Container(
          height: appBarHeight,
          alignment: Alignment.center,
          child: AppBar(
            title: Text(titleText),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight + topPadding); // AppBar 높이와 상단 패딩을 합한 값을 반환
}
