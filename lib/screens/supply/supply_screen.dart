import 'package:flutter/material.dart';

class SupplyScreen extends StatefulWidget {
  const SupplyScreen({super.key});

  @override
  _SupplyScreenState createState() => _SupplyScreenState();
}

class _SupplyScreenState extends State<SupplyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supply Screen'),
      ),
      body: Container(
          // Add your widget tree here
          ),
    );
  }
}
