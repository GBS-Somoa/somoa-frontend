import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeviceDetailScreen extends StatefulWidget {
  final String deviceId;

  DeviceDetailScreen({super.key, required this.deviceId});

  @override
  _DeviceDetailScreenState createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  bool isLoading = true;
  Map<String, dynamic>? deviceInfo;
  List<dynamic>? relatedOrders;
  List<dynamic>? consumables;

  @override
  void initState() {
    super.initState();
    fetchDeviceInfo();
  }

  Future<void> fetchDeviceInfo() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Send device lookup request to the server
      final response = await http
          .get(Uri.parse('YOUR_DEVICE_LOOKUP_API_URL/${widget.deviceId}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          deviceInfo = data['deviceInfo'];
          relatedOrders = data['relatedOrders'];
          consumables = data['consumables'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch device info');
      }
    } catch (error) {
      print(error);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Detail'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // Render device summary
                Text('Device Summary: ${deviceInfo?['summary']}'),

                // Render related orders
                Text('Related Orders:'),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: relatedOrders?.length ?? 0,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(relatedOrders?[index]['orderNumber']),
                      subtitle: Text(relatedOrders?[index]['orderStatus']),
                    );
                  },
                ),

                // Render consumables
                Text('Consumables:'),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: consumables?.length ?? 0,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(consumables?[index]['name']),
                      subtitle: Text(consumables?[index]['status']),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
