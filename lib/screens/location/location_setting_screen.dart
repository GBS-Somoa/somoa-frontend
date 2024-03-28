import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:somoa/providers/user_provider.dart';
import 'package:somoa/widgets/list_container_widget.dart';
import 'package:somoa/widgets/menu_bar_widget.dart';
import 'package:http/http.dart' as http;

class LocationSettingScreen extends StatefulWidget {
  const LocationSettingScreen({super.key});

  @override
  _LocationSettingScreenState createState() => _LocationSettingScreenState();
}

class Group {
  int id;
  String name;
  String myRole;
  bool alarm;

  Group({required this.id, required this.name, required this.myRole, required this.alarm});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['groupId'] as int,
      name: json['groupName'] as String,
      myRole: json['role'] as String,
      alarm: json['alarm'] as bool,
    );
  }
}

class Member {
  String name;
  String id;
  String role;

  Member({required this.name, required this.id, required this.role});

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      name: json['userNickname'] as String,
      id: json['userUsername'] as String,
      role: json['role'] as String,
    );
  }
}

class _LocationSettingScreenState extends State<LocationSettingScreen> {
  static const String ADMIN = '관리자';
  static const String ALL_GRANTED = '모든 권한';
  static const String ONLY_SUPPLY = '소모품 관리';
  static const List roles = [ADMIN, ALL_GRANTED, ONLY_SUPPLY];
  static const storage = FlutterSecureStorage();

  Group _group = Group(id: 0, name: '', myRole: '', alarm: false);
  Member _admin = Member(name: '', id: '', role: '');

  List<Member> _groupMembers = [];

  int groupId = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        groupId = args;
      }
    });
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });

    await fetchGroup();
    await fetchGroupMembers();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchGroup() async {
    final accessToken = await storage.read(key: 'accessToken');

    String serverUrl = dotenv.get("SERVER_URL");
    final url = Uri.parse('$serverUrl' 'groups/$groupId');

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
          print(data['data']);
          final groupJson = data['data'];
          setState(() {
            _group = Group.fromJson(groupJson);
          });
        }
      } else {
        print('장소 로딩 실패');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> changeGroupName(String name) async {
    final accessToken = await storage.read(key: 'accessToken');

    String serverUrl = dotenv.get("SERVER_URL");
    final url = Uri.parse('$serverUrl' 'groups/$groupId');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'groupName': name,
        }),
      );

      if (response.statusCode != 200) {
        print("장소 이름 바꾸기 실패");
      }

    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> fetchGroupMembers() async {
    final accessToken = await storage.read(key: 'accessToken');

    String serverUrl = dotenv.get("SERVER_URL");
    final url = Uri.parse('$serverUrl' 'groups/$groupId/users');

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
          final List<dynamic> membersJson = data['data'];

          setState(() {
            final adminJson = membersJson.firstWhere(
                  (member) => member['role'] == ADMIN,
              orElse: () => null,
            );
            if (adminJson != null) {
              _admin = Member.fromJson(adminJson);
            } else {
              _admin = Member(name: 'N/A', id: 'N/A', role: ADMIN);
            }

            _groupMembers = membersJson
                .where((member) => member['role'] != ADMIN)
                .map((member) => Member.fromJson(member))
                .toList();
          });
        }
      } else {
        print('그룹 멤버 로딩 실패');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _showEditDialog(BuildContext context, String currentLocationName) async {
    TextEditingController _textEditingController = TextEditingController(text: currentLocationName);

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
              '장소 이름 편집',
              style: TextStyle(fontSize: 18)
          ),
          content: TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(hintText: '장소 이름을 입력하세요'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('저장'),
              onPressed: () {
                setState(() {
                  changeGroupName(_textEditingController.text);
                  _group.name = _textEditingController.text;
                });
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      return Scaffold(
        appBar: _isLoading ? MenuBarWidget(titleText: '') :
        MenuBarWidget(titleText: '${_group.name} 설정'),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator()) :
        SingleChildScrollView(
          child: Column(
            children: [
              ListContainerWidget(
                  children: [
                    ListTile(
                      title: Text('장소 이름'),
                      subtitle: Text(_group.name, style: TextStyle(color: Colors.indigo),
                      ),
                      onTap: () {
                        _showEditDialog(context, _group.name);
                      },
                    ),
                  ]
              ),
              ListContainerWidget(
                  children: [
                    SwitchListTile(
                      title: Text('알림'),
                      subtitle: Text('장소에 대한 알림을 받습니다.', style: TextStyle(color: Colors.indigo)),
                      value: _group.alarm,
                      onChanged: (value) {
                        setState(() {
                          _group.alarm = value;
                        });
                      },
                    ),
                  ]
              ),
              const ListContainerWidget(
                  children: [
                    ListTile(
                      title: Text('소모품 주문 내역'),
                    ),
                  ]
              ),
              ListContainerWidget(
                  title: ADMIN,
                  children: [
                    Align(
                        child: ListTile(
                            title: Text(_admin.name),
                            subtitle: Text(_admin.id, style: TextStyle(color: Colors.grey),)
                        )
                    ),
                  ]
              ),
              _groupMembers.length > 0 ?
              ListContainerWidget(
                title: '멤버',
                children: _groupMembers.map((member) {
                  return ListTile(
                    title: Text(member.name),
                    subtitle: Text(member.role, style: TextStyle(color: Colors.indigo)),
                    trailing: SizedBox(
                      width: 48,
                      height: 48,
                      child: GestureDetector(
                        onTap: () {
                          print("hehe");
                        },
                        child: member.id != userProvider.username && (_group.myRole == ADMIN || _group.myRole == ALL_GRANTED)
                            ? Icon(Icons.remove_circle_outline, color: Colors.red)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ) : const SizedBox(),
            ],
          ),
        ),
      );
    });
  }
}
