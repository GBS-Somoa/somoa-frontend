import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somoa/providers/user_provider.dart';
import 'package:somoa/screens/device/device_list_screen.dart';
import 'package:somoa/screens/notification/notification_screen.dart';
import 'package:somoa/screens/profile/profile_screen.dart';
import 'package:somoa/screens/supply/supply_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Widget> _screens = [
    DeviceScreen(),
    SupplyScreen(),
    NotificationScreen(),
    ProfileScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      // 사용자 이름을 가져옵니다.
      String username = userProvider.username ?? "";

      // 사용자 이름이 없는 경우 로그인 화면으로 이동합니다.
      if (username == "") {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/login');
        });
        return Container(); // 빈 컨테이너를 반환하여 렌더링하지 않습니다.
      }

      // 사용자 이름이 있는 경우(로그인 한 경우)에만 앱 화면 진입 가능
      return Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.widgets,
                  size: 30,
                ),
                label: '기기',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.inventory_outlined,
                  size: 30,
                ),
                label: '소모품',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.notifications,
                  size: 30,
                ),
                label: '알림',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                  size: 30,
                ),
                label: '내 정보',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue[900],
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed),
      );
    });
  }
}
