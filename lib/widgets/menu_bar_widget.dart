import 'package:flutter/material.dart';

class MenuBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final double appBarHeight;
  final double topPadding;
  final String? title;

  const MenuBarWidget({
    super.key,
    required this.titleText,
    this.appBarHeight = 85.0,
    this.topPadding = 25.0,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: topPadding),
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
  Size get preferredSize => Size.fromHeight(appBarHeight + topPadding);
}
