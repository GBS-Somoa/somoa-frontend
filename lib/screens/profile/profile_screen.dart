import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somoa/providers/user_provider.dart';
import 'package:somoa/utils/bottom_navigation_bar.dart';

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
        body: const Center(
          child: Text('Profile Screen'),
        ),
        bottomNavigationBar: const BottomNavBar(
          selectedIndex: 3,
        ),
      );
    });
  }
}
