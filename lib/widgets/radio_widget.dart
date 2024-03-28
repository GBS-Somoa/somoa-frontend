import 'package:flutter/material.dart';

class RadioWidget extends StatelessWidget {
  final String title;
  final List<String> choices;
  final String selectedValue;
  final String noText;
  final Function(String) onChanged;

  const RadioWidget({
    super.key,
    required this.title,
    required this.choices,
    required this.selectedValue,
    this.noText = '취소',
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Material(
        borderRadius: BorderRadius.circular(30),
        elevation: 2.0,
        child: Container(
          padding: EdgeInsets.fromLTRB(25, 20, 25, 0),
          height: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...choices.map((choice) {
                return RadioListTile<String>(
                  title: Text(choice),
                  value: choice,
                  activeColor: Colors.indigo,
                  groupValue: selectedValue,
                  onChanged: (value) {
                    onChanged(value!);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              const SizedBox(height: 10),
              ListTile(
                title: Text(
                  noText,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

