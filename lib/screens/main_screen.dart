import 'package:flutter/material.dart';
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
    // Add your screens here
    // Example: Screen1(),
    //          Screen2(),
    //          Screen3(),
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
  }
}
