import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:somoa/screens/device/device_detail_screen.dart';
import 'package:somoa/screens/device/device_list_screen.dart';
import 'package:somoa/screens/order/order_list_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _loadNotifications();
        });
      }
    });
    _loadNotifications();
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
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final String storedNotifications = prefs.getString('notifications') ?? '[]';
    final List<dynamic> notificationsList = json.decode(storedNotifications);

    // 날짜에 따라 알림을 내림차순으로 정렬합니다.
    notificationsList.sort((a, b) {
      return -DateTime.parse(a['date']).compareTo(DateTime.parse(b['date']));
    });

    setState(() {
      notifications = notificationsList.cast<Map<String, dynamic>>();
      _isLoading = false;
    });
  }

  Icon getIconFromData(String? iconType) {
    switch (iconType) {
      case "clean":
        return const Icon(Icons.cleaning_services_outlined,
            color: Colors.blue, size: 30.0);
      case "add":
        return const Icon(Icons.add_circle_outline_sharp,
            color: Colors.blue, size: 30.0);
      case "change":
        return const Icon(Icons.change_circle, color: Colors.blue, size: 30.0);
      default:
        return const Icon(Icons.notifications_outlined,
            color: Colors.blue, size: 30.0);
    }
  }

  String _getSectionTitle(DateTime notificationDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = today
        .difference(DateTime(notificationDate.year, notificationDate.month,
            notificationDate.day))
        .inDays;

    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '1일 전';
    } else if (difference <= 6) {
      return '$difference일 전';
    } else {
      return ''; // 6일 이상이면 비어있는 문자열 반환
    }
  }

  Future<void> _deleteAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    await prefs.setString('notifications', '[]');
    setState(() {
      notifications = [];
    });
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('모든 알림 삭제'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('모든 알림을 삭제하시겠습니까?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _deleteAllNotifications();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 알림을 날짜별로 분류
    final Map<String, List<Map<String, dynamic>>> sortedNotifications = {};
    for (var notification in notifications) {
      final date = DateTime.parse(notification['date']);
      final sectionTitle = _getSectionTitle(date);

      if (sectionTitle.isNotEmpty) {
        if (!sortedNotifications.containsKey(sectionTitle)) {
          sortedNotifications[sectionTitle] = [];
        }
        sortedNotifications[sectionTitle]!.add(notification);
      }
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('알림', style: TextStyle(fontSize: 26.0)),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete_all') {
                _showDeleteConfirmationDialog();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'delete_all',
                  height: BorderSide.strokeAlignCenter,
                  child: Text('모든 알림 삭제'),
                ),
              ];
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: sortedNotifications.isNotEmpty
                  ? ListView(
                      children: sortedNotifications.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 제목을 카드 외부에 표시
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 2.0),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // Card 위젯 내에 알림 목록을 표시
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  child: Column(
                                    children: entry.value.map((notification) {
                                      // 알림에서 data 객체
                                      final Map<String, dynamic> data =
                                          json.decode(notification['data']);
                                      final String? path = data['path'];
                                      return Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2.0),
                                            child: Dismissible(
                                              key: Key(notification['date']),
                                              onDismissed: (direction) async {
                                                notifications
                                                    .remove(notification);
                                                final prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                await prefs.reload();
                                                String encodedData =
                                                    json.encode(notifications);
                                                setState(() {
                                                  prefs.setString(
                                                      'notifications',
                                                      encodedData);
                                                });
                                              },
                                              child: ListTile(
                                                leading: getIconFromData(
                                                    data['icon']),
                                                onTap: () async {
                                                  notifications
                                                      .remove(notification);
                                                  final prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  await prefs.reload();
                                                  String encodedData = json
                                                      .encode(notifications);
                                                  setState(() {
                                                    prefs.setString(
                                                        'notifications',
                                                        encodedData);
                                                  });
                                                  if (path != null) {
                                                    if (path ==
                                                        'DeviceDetailScreen') {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  DeviceDetailScreen(
                                                                      deviceId:
                                                                          data['pathData']
                                                                              as String)));
                                                    } else if (path ==
                                                        'OrderListScreen') {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  OrderListScreen(
                                                                      groupId: int
                                                                          .parse(
                                                                              data['pathData']))));
                                                    } else if (path ==
                                                        'DeviceListScreen') {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const DeviceScreen()));
                                                    } else {
                                                      print(
                                                          'Unknown path: $path');
                                                    }
                                                  } else {
                                                    print('path is null');
                                                  }
                                                },
                                                title: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 5.0),
                                                  child: Text(
                                                      notification['title'],
                                                      style: const TextStyle(
                                                        fontSize: 17.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      )),
                                                ),
                                                subtitle: Text(
                                                    notification['body'],
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                      color: Colors.grey[700],
                                                    )),
                                                trailing: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      DateFormat('a h:mm')
                                                          .format(
                                                            DateTime.parse(
                                                                notification[
                                                                    'date']),
                                                          )
                                                          .replaceAll(
                                                              'AM', '오전')
                                                          .replaceAll(
                                                              'PM', '오후'),
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // 마지막 항목이 아닐 경우에만 구분선 추가
                                          if (entry.value.last != notification)
                                            Divider(
                                              color: Colors
                                                  .grey[500], // 선의 색상, 짙은 정도 조절
                                              thickness: 0.5, // 선의 두께 조절
                                              indent: 30, // 선의 시작 위치
                                              endIndent: 30, // 선의 끝 위치
                                            ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    )
                  : const Center(
                      child: Text('알림 없음'),
                    ),
            ),
    );
  }
}
