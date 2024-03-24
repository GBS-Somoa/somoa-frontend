import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somoa/providers/user_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 임시 데이터 -> 사용자가 포함된 장소 데이터 서버로부터 받아야함 (-> 전역 상태로 저장 후 받아서 써야함)
  static const locationList = ['내 자취방', '부모님집', '할머니댁'];
  late String _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = locationList.first;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // 사용자 이름을 가져옵니다.
        String username = userProvider.username;

        // 사용자 이름이 없는 경우 로그인 화면으로 이동합니다.
        if (username.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return Container(); // 빈 컨테이너를 반환하여 렌더링하지 않습니다.
        }

        // 사용자 이름이 있는 경우 메인 페이지를 표시합니다.
        return Scaffold(
          appBar: AppBar(
            title: Text(username != "" ? 'Main Page - $username' : 'Main Page'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  userProvider.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              )
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.home),
                      SizedBox(
                        width: 150.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedLocation,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedLocation = newValue ?? '';
                              });
                            },
                            items: locationList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      showMenu(
                        context: context,
                        position: const RelativeRect.fromLTRB(100, 100, 0, 0),
                        items: [
                          const PopupMenuItem(
                            value: '장소 추가',
                            child: Text('장소 추가'),
                          ),
                          const PopupMenuItem(
                            value: '장소 관리',
                            child: Text('장소 관리'),
                          ),
                          const PopupMenuItem(
                            value: '기기 추가',
                            child: Text('기기 추가'),
                          ),
                          const PopupMenuItem(
                            value: '주문 목록',
                            child: Text('주문 목록'),
                          ),
                        ],
                        elevation: 8.0,
                      ).then((value) {
                        if (value != null) {
                          // Handle menu item selection here
                          print('Selected: $value');
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          body: const Center(
            child: Text("main page"),
          ),
        );
      },
    );
  }
}
