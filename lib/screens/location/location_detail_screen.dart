import 'package:flutter/material.dart';

class LocationDetailScreen extends StatefulWidget {
  @override
  _LocationDetailScreenState createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  bool _notificationToggle = false;
  String _locationName = '';
  String _adminName = '';
  List<String> _groupMembers = [];
  List<String> _orderHistory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Detail'),
      ),
      body: Column(
        children: [
          Text('Location Name: $_locationName'),
          SwitchListTile(
            title: Text('Notification'),
            value: _notificationToggle,
            onChanged: (value) {
              setState(() {
                _notificationToggle = value;
              });
            },
          ),
          Text('Admin Name: $_adminName'),
          Text('Group Members:'),
          ListView.builder(
            shrinkWrap: true,
            itemCount: _groupMembers.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_groupMembers[index]),
              );
            },
          ),
          Text('Order History:'),
          ListView.builder(
            shrinkWrap: true,
            itemCount: _orderHistory.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_orderHistory[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}
