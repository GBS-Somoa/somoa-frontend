import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
  });

  // final void Function(int) onItemTapped;
  void onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        if (selectedIndex != 0) {
          Navigator.pushReplacementNamed(context, '/main');
        }
        break;
      case 1:
        if (selectedIndex != 1) {
          Navigator.pushReplacementNamed(context, '/supply');
        }
        break;
      case 2:
        if (selectedIndex != 2) {
          Navigator.pushReplacementNamed(context, '/notification');
        }
        break;
      case 3:
        if (selectedIndex != 3) {
          Navigator.pushReplacementNamed(context, '/profile');
        }
        break;
    }
    print('Selected index: $index');
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            size: 30,
          ),
          label: '장소',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.inventory_2,
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
      currentIndex: selectedIndex,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey[500],
      onTap: (index) => onItemTapped(context, index),
    );
  }
}
