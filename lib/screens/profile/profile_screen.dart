import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:somoa/providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                userProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(
                  height: 150,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          '${userProvider.nickname}',
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        Text('${userProvider.username}')
                      ],
                    ),
                  ),
                ),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Card(
                      child: ListTile(
                        title: Text('프로필 관리'),
                        onTap: () {
                          print('Item 1 tapped');
                        },
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: Text('장소 관리'),
                        onTap: () {
                          print('Item 2 tapped');
                        },
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: Text('즐겨찾는 쇼핑몰 관리'),
                        onTap: () {
                          print('Item 3 tapped');
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '나의 주문 목록',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 16),
                      )
                      // TODO: orderList 들어감
                    ])
              ],
            ),
          ),
        ),
      );
    });
  }
}
