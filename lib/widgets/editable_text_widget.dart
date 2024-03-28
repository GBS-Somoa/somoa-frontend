import 'package:flutter/material.dart';

class EditableTextWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const EditableTextWidget({
    Key? key,
    required this.controller,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.0),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
        ),
        cursorColor: Colors.grey,
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }
}
