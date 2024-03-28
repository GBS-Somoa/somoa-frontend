import 'package:somoa/screens/device/device_list_screen.dart';

class Device {
  final String id;
  final String nickname;
  final String type;
  final String model;
  final String manufacturer;
  final List<Supply> supplies;

  Device({
    required this.id,
    required this.nickname,
    required this.type,
    required this.model,
    required this.manufacturer,
    required this.supplies,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      nickname: json['nickname'],
      type: json['type'],
      model: json['model'],
      manufacturer: json['manufacturer'],
      supplies: (json['supplies'] as List<dynamic>)
          .map((supplyJson) => Supply.fromJson(supplyJson))
          .toList(),
    );
  }
}
