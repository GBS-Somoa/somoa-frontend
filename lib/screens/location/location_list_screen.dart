
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:somoa/providers/user_provider.dart';
import 'package:somoa/widgets/list_container_widget.dart';
import 'package:somoa/widgets/menu_bar_widget.dart';

class LocationListScreen extends StatefulWidget {
  const LocationListScreen({super.key});

  @override
  _LocationListScreenState createState() => _LocationListScreenState();
}

class _LocationListScreenState extends State<LocationListScreen> {

  static const storage = FlutterSecureStorage();
  List<Group> groups = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await getGroupList();
  }

  Future<void> getGroupList() async {
    final accessToken = await storage.read(key: 'accessToken');

    String serverUrl = dotenv.get("SERVER_URL");
    final url = Uri.parse('$serverUrl' 'groups');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);

        if (data['data'] != null) {
          final List<dynamic> groupsJson = data['data'];
          setState(() {
            groups = groupsJson.map((group) => Group.fromJson(group)).toList();
          });
        }
      } else {
        print('그룹 로딩 실패');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateGroupOrderOnServer() async {
    final accessToken = await storage.read(key: 'accessToken');

    String serverUrl = dotenv.get("SERVER_URL");
    final url = Uri.parse('$serverUrl' 'groups/group-order');

    List<int> groupIds = groups.map((group) => group.id).toList();

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'groupIds': groupIds,
        }),
      );

      if (response.statusCode != 200) {
        print(response.statusCode);
        print('그룹 순서 업데이트 실패');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      return Scaffold(
        appBar: const MenuBarWidget(titleText: '장소 관리'),
        body: ReorderableListView(
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final Group item = groups.removeAt(oldIndex);
              groups.insert(newIndex, item);
              updateGroupOrderOnServer();
            });
          },
          children: List.generate(groups.length, (index) {
            return Dismissible(
              key: ValueKey(groups[index].id),
              child: ListContainerWidget(
                children: [
                  ListTile(
                    title: Text(groups[index].name, style: const TextStyle(fontSize: 20)),
                    subtitle: Text(
                      groups[index].managerId == userProvider.username
                          ? '관리자 : 나'
                          : '관리자 : ${groups[index].managerName}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/locationSetting', arguments: groups[index].id);
                    },
                    trailing: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.menu, color: Colors.grey), // 햄버거 아이콘
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      );
    }
    );
  }
}

class Group {
  int id;
  String name;
  String managerId;
  String managerName;
  int order;

  Group({required this.id, required this.name, required this.managerId, required this.managerName, required this.order});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['groupId'] as int,
      name: json['groupName'] as String,
      managerId: json['managerUsername'] as String,
      managerName: json['managerNickname'] as String,
      order: json['orderedNum'] as int,
    );
  }
}
