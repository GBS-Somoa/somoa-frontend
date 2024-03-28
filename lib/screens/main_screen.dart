import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:somoa/providers/user_provider.dart';
import 'package:somoa/screens/device/device_list_screen.dart';
import 'package:somoa/screens/notification/notification_screen.dart';
import 'package:somoa/screens/profile/profile_screen.dart';
import 'package:somoa/screens/supply/supply_screen.dart';

class MainScreen extends StatefulWidget {
  final int? index;

  MainScreen({Key? key, this.index}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime? currentBackPressTime;

  void _goBack() async {
    DateTime currentTime = DateTime.now();

    if (currentBackPressTime == null ||
        currentTime.difference(currentBackPressTime!) >
            const Duration(seconds: 2)) {
      currentBackPressTime = currentTime;
      Fluttertoast.showToast(
        msg: "'뒤로' 버튼을 한번 더 누르시면 종료됩니다.",
      );
    } else {
      SystemNavigator.pop();
    }
  }

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    // index가 null이 아니면 해당 값을 사용하고, null이면 0을 기본값으로 사용
    _selectedIndex = widget.index ?? 0;
  }

  final List<Widget> _screens = [
    const DeviceScreen(),
    const SupplyScreen(),
    const NotificationScreen(),
    const ProfileScreen()
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
      return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          _goBack();
        },
        child: Scaffold(
          body: _screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.widgets, size: 30),
                label: '기기',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_outlined, size: 30),
                label: '소모품',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications, size: 30),
                label: '알림',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 30),
                label: '내 정보',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue[900],
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      );
    });
  }
}
