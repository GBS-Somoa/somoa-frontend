import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:somoa/providers/user_provider.dart';
import 'package:somoa/screens/device/device_create_screen.dart';
import 'package:somoa/screens/location/location_detail_screen.dart';
import 'package:somoa/screens/notification/notification_screen.dart';
import 'package:somoa/screens/order/order_list_screen.dart';
import 'package:somoa/screens/profile/location_setting_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'dart:convert';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  print('백그라운드 메세지 제목: ${message.notification?.title}');
  print('백그라운드 메세지 내용: ${message.notification?.body}');

  if (message.notification != null) {
    await saveNotification(message.notification!.title!,
        message.notification!.body!, message.data);
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> saveNotification(
    String title, String body, Map<String, dynamic> data) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();

  // 알림 리스트를 가져옴. 없으면 빈 리스트를 사용
  final String storedNotifications = prefs.getString('notifications') ?? '[]';
  List<dynamic> notificationsList = json.decode(storedNotifications);

  final notification = {
    "title": title,
    "body": body,
    "date": DateTime.now().toIso8601String(),
    "data": json.encode(data)
  };

  print(notification['date']);
  print(notification['data']);
  // 새 알림을 리스트에 추가
  notificationsList.add(notification);

  // 6일 전의 날짜를 계산
  final sixDaysAgo = DateTime.now().subtract(const Duration(days: 6));

  // 6일보다 오래된 알림 필터링
  notificationsList = notificationsList.where((notification) {
    final notificationDate = DateTime.parse(notification['date']);
    return notificationDate.isAfter(sixDaysAgo);
  }).toList();

  // 업데이트된 알림 리스트를 다시 저장
  await prefs.setString('notifications', json.encode(notificationsList));
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const FlutterSecureStorage storage = FlutterSecureStorage();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    importance: Importance.max,
  );

  // final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
    navigatorKey.currentState
        ?.pushReplacementNamed('/mainScreen', arguments: 2);
  });

  await flutterLocalNotificationsPlugin.cancelAll();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    navigatorKey.currentState
        ?.pushReplacementNamed('/mainScreen', arguments: 2);
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('알림 제목: ${message.notification?.title}');
    print('알림 내용: ${message.notification?.body}');
    print('알림 데이터: ${message.data}');

    RemoteNotification? notification = message.notification;

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      saveNotification(message.notification!.title!,
          message.notification!.body!, message.data);
    }

    if (notification != null) {
      flutterLocalNotificationsPlugin
          .show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  importance: Importance.max,
                  priority: Priority.high,
                ),
              ))
          .then((_) {
        Future.delayed(const Duration(seconds: 5), () {
          flutterLocalNotificationsPlugin.cancel(notification.hashCode);
        });
      });
    }
  });

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  String? token = await messaging.getToken();
  await storage.write(key: 'fcmToken', value: token);

  print('FCM Token: $token');

  await dotenv.load();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => UserProvider()),
    ], child: const MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 돌아왔을 때 모든 알림 취소
      flutterLocalNotificationsPlugin.cancelAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
          backgroundColor:
              Colors.transparent, // Set app bar background color to transparent
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
      home: FutureBuilder(
        future: Provider.of<UserProvider>(context, listen: false)
            .checkLoginAndInitialMessage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // 로그인 성공하고 알림 클릭으로 앱 시작
            if (snapshot.data?['isLoggedIn'] == true &&
                snapshot.data?['hasInitialMessage'] == true) {
              return MainScreen(index: 2); // 알림 탭으로 이동
            }
            // 로그인만 성공
            else if (snapshot.data?['isLoggedIn'] == true) {
              return MainScreen(); // 기본 탭으로 이동
            } else {
              return const LoginScreen(); // 로그인 실패시 로그인 화면으로 이동
            }
          }
          return const SplashScreen(); // 로딩 중에는 스플래시 화면을 보여줍니다.
        },
      ),
      routes: {
        '/registration': (context) => const RegistrationScreen(),
        '/login': (context) => const LoginScreen(),
        '/main': (context) => MainScreen(),
        '/addDevice': (context) => DeviceCreateScreen(),
        '/locationSetting': (context) => LocationSettingScreen(),
        '/orderList': (context) => OrderListScreen(
              groupId: '',
            ),
        '/locationDetail': (context) => LocationDetailScreen(),
        '/notification': (context) => const NotificationScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/mainScreen') {
          final args = settings.arguments as int?;
          return MaterialPageRoute(builder: (context) {
            return MainScreen(index: args ?? 0);
          });
        }
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // 로딩 인디케이터
      ),
    );
  }
}
