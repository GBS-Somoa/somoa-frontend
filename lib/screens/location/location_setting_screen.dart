import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:somoa/models/member_model.dart';
import 'package:somoa/providers/user_provider.dart';
import 'package:somoa/widgets/confirm_widget.dart';
import 'package:somoa/widgets/list_container_widget.dart';
import 'package:somoa/widgets/menu_bar_widget.dart';
import 'package:http/http.dart' as http;
import 'package:somoa/widgets/radio_widget.dart';

class LocationSettingScreen extends StatefulWidget {
  const LocationSettingScreen({super.key});

  @override
  _LocationSettingScreenState createState() => _LocationSettingScreenState();
}

class MyGroup {
  int id;
  String name;
  String myRole;
  bool alarm;

  MyGroup({required this.id, required this.name, required this.myRole, required this.alarm});

  factory MyGroup.fromJson(Map<String, dynamic> json) {
    return MyGroup(
      id: json['groupId'] as int,
      name: json['groupName'] as String,
      myRole: json['role'] as String,
      alarm: json['alarm'] as bool,
    );
  }
}

class _LocationSettingScreenState extends State<LocationSettingScreen> {
  static const String ADMIN = '관리자';
  static const String ALL_GRANTED = '모든 권한';
  static const String ONLY_SUPPLY = '소모품 관리';
  static List<String> roles = [ALL_GRANTED, ONLY_SUPPLY];
  static const storage = FlutterSecureStorage();

  MyGroup _group = MyGroup(id: 0, name: '', myRole: '', alarm: false);
  Member _admin = Member(id: 0, name: '', username: '', role: '');

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
    final url = getApiUrl('groups/$groupId');

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
            _group = MyGroup.fromJson(groupJson);
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
    final url = getApiUrl('groups/$groupId');

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
    final url = getApiUrl('groups/$groupId/users');

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
              _admin = Member(id: 0, name: 'N/A', username: 'N/A', role: ADMIN);
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

  Future<void> toggleAlarm(bool value) async {
    final accessToken = await storage.read(key: 'accessToken');
    final url = getApiUrl('groups/$groupId/alarm');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'alarm': value,
        }),
      );

      if (response.statusCode != 200) {
        print(response.body);
        print("알림 토글 실패");
      } else {
        setState(() {
          _group.alarm = value;
        });
      }

    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> changeMemberRole(Member member, String role) async {
    final accessToken = await storage.read(key: 'accessToken');
    final url = getApiUrl('groups/$groupId/users/${member.id}/permission');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'role': role,
        }),
      );

      if (response.statusCode != 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);
        print(data);
        print("멤버 역할 변경 실패");
      } else {
        setState(() {
          member.role = role;
        });
      }

    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteMember(int id) async {
    final accessToken = await storage.read(key: 'accessToken');
    final url = getApiUrl('groups/$groupId/users');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'userId': id
        }),
      );

      if (response.statusCode != 200) {
        print(response.body);
        print("멤버 삭제 실패");
      } else {
        setState(() {
          _groupMembers.removeWhere((member) => member.id == id);
        });
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

  Uri getApiUrl(String path) {
    String serverUrl = dotenv.get("SERVER_URL");
    return Uri.parse('$serverUrl$path');
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
                          toggleAlarm(value);
                        });
                      },
                    ),
                  ]
              ),
              ListContainerWidget(
                children: [
                  ListTile(
                    title: Text('소모품 주문 내역'),
                    onTap: () {
                      Navigator.pushNamed(context, '/orderList', arguments: _group.id);
                    },
                  ),
                ],
              ),
              ListContainerWidget(
                  title: ADMIN,
                  children: [
                    Align(
                        child: ListTile(
                            title: Text(_admin.name),
                            subtitle: Text(_admin.username, style: TextStyle(color: Colors.grey),)
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
                    onTap: _group.myRole != ONLY_SUPPLY && userProvider.username != member.username ? () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        builder: (BuildContext context) {
                          return RadioWidget(
                            title: '${member.name} 님에게 허용할 기능을 선택하세요.',
                            choices: roles,
                            selectedValue: member.role,
                            onChanged: (String selectedValue) {
                              changeMemberRole(member, selectedValue);
                            },
                          );
                        },
                      );
                    } : null,
                    trailing: SizedBox(
                      width: 48,
                      height: 48,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                            ),
                            builder: (BuildContext context) {
                              return ConfirmWidget(
                                title: '${member.name} 님을 삭제할까요?',
                                text: '삭제한 멤버는 ${_group.name} 기기의 소모품을 관리할 수 없게 됩니다.',
                                onYes: () {
                                  deleteMember(member.id);
                                },
                                yesText: '삭제',
                              );
                            },
                          );
                        },
                        child: member.username != userProvider.username && (_group.myRole == ADMIN || _group.myRole == ALL_GRANTED)
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
