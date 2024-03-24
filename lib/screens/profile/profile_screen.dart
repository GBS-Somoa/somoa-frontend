import 'package:flutter/material.dart';
import 'package:somoa/utils/bottom_navigation_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text('Profile Screen'),
      ),
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 3,
      ),
    );
  }
}
