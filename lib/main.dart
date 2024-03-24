import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somoa/providers/user_provider.dart';
import 'package:somoa/screens/notification/notification_screen.dart';
import 'package:somoa/screens/profile/profile_screen.dart';
import 'package:somoa/screens/supply/supply_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Somoa',
        theme: ThemeData(
          primaryColor: Colors.blue[900],
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.grey,
            backgroundColor: Colors.grey[100],
          ),
          focusColor: Colors.redAccent, // Color for focus highlight
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors
                .transparent, // Set app bar background color to transparent
            elevation: 0, // Remove app bar elevation
            iconTheme: IconThemeData(color: Colors.black), // Set icon color
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor:
                  Colors.blue[900], // Text color for elevated buttons
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue[900], // Text color for text buttons
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  Colors.blue[900], // Border color for outlined buttons
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            contentPadding: EdgeInsets.all(15.0),
            labelStyle: TextStyle(color: Colors.black),
          ),
          popupMenuTheme: const PopupMenuThemeData(
            color: Colors.white,
            textStyle: TextStyle(color: Colors.black),
          ),
        ),
        home: const MainScreen(),
        routes: {
          '/registration': (context) => const RegistrationScreen(),
          '/login': (context) => LoginScreen(),
          '/main': (context) => const MainScreen(),
          '/supply': (context) => const SupplyScreen(),
          '/notification': (context) => const NotificationScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
