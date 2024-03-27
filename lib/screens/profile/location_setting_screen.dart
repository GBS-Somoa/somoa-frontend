import 'package:flutter/material.dart';
import 'package:somoa/widgets/list_container_widget.dart';
import 'package:somoa/widgets/menu_bar_widget.dart';

class LocationSettingScreen extends StatefulWidget {
  @override
  _LocationSettingScreenState createState() => _LocationSettingScreenState();
}

class Member {
  String name;
  String id;
  String role;

  Member({required this.name, required this.id, required this.role});
}

class _LocationSettingScreenState extends State<LocationSettingScreen> {
  bool _notificationToggle = false;
  final String _locationName = '우리집';

  final Member _admin = Member(name: '김 현창', id: 'hspear', role: '관리자');

  final List<Member> _groupMembers = [
    Member(name: '심 상익', id: 'alice01', role: '소모품 관리'),
    Member(name: '이 성은', id: 'charlie03', role: '모든 권한'),
    Member(name: '이 시은', id: 'bravo23', role: '모든 권한'),
    Member(name: '원 종현', id: 'zoe142', role: '소모품 관리'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titleText: '$_locationName 설정'),
      body: SingleChildScrollView(
        // ListView와 같이 스크롤 가능한 위젯이 중첩될 때 사용합니다.
        child: Column(
          children: [
            ListContainerWidget(
                children: [
                  ListTile(
                      title: Text('장소 이름'),
                      subtitle: Text(_locationName, style: TextStyle(color: Colors.indigo),)
                  ),
                ]
            ),
            ListContainerWidget(
                children: [
                  SwitchListTile(
                    title: Text('알림'),
                    value: _notificationToggle,
                    onChanged: (value) {
                      setState(() {
                        _notificationToggle = value;
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
                title: '관리자',
                children: [
                  Align(
                      child: ListTile(
                          title: Text(_admin.name),
                          subtitle: Text(_admin.id, style: TextStyle(color: Colors.grey),)
                      )
                  ),
                ]
            ),
            ListContainerWidget(
              title: '멤버',
              children: _groupMembers.map((member) {
                return ListTile(
                  title: Text(member.name),
                  subtitle: Text(member.role, style: TextStyle(color: Colors.indigo)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
