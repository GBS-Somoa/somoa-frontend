import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:somoa/screens/auth/registration_screen.dart';
import 'package:somoa/providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _keepLoggedIn = false;

  Future<void> _saveKeepLoggedIn(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepLoggedIn', value);
  }

  Future<void> login(BuildContext context) async {
// Check if test mode is enabled
    bool testMode = false; // Set this flag to true to enable test mode

    // If test mode is enabled, simulate a successful login without making a network call
    if (testMode) {
      print("아무거나");
      _simulateSuccessfulLogin(context);
      return;
    }

    // 로그인 요청을 보낼 서버의 URL
    String url = dotenv.get("SERVER_URL");

    // 사용자가 입력한 아이디와 비밀번호
    String id = idController.text;
    String password = passwordController.text;

    // 서버에 보낼 데이터
    Map<String, String> data = {'username': id, 'password': password};

    // 로그인 요청 보내기
    try {
      final response = await http.post(
        Uri.parse(url + 'user/login'),
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );

      // 서버에서 받은 응답 확인
      if (response.statusCode == 200) {
        // 로그인 성공
        if (context.mounted) {
          print('로그인 성공');
          print(response.body);
          await _saveKeepLoggedIn(_keepLoggedIn);
          Provider.of<UserProvider>(context, listen: false).login(
              keepLoggedIn: _keepLoggedIn,
              username: id,
              password: password,
              nickname: jsonDecode(response.body)['nickname'] ?? '임시 닉네임',
              accessToken: jsonDecode(response.body)['accessToken'],
              refreshToken: jsonDecode(response.body)['refreshToken']);
          Navigator.pushReplacementNamed(context, '/main');
        }
      } else {
        // 로그인 실패
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('로그인 실패'),
              content: const Text('아이디 또는 비밀번호가 올바르지 않습니다.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print('로그인 요청 중 오류 발생: $e');
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('오류'),
            content: const Text('로그인 요청 중 오류가 발생했습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    }
  }

  // Function to simulate a successful login
  void _simulateSuccessfulLogin(BuildContext context) {
    if (context.mounted) {
      print({"id": idController.text, "password": passwordController.text});
      Provider.of<UserProvider>(context, listen: false).login(
        keepLoggedIn: _keepLoggedIn,
        username: idController.text,
        password: passwordController.text,
        nickname: "테스트 모드",
        accessToken: "asdf",
        refreshToken: "qwer",
      );
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '로그인',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: idController,
                      decoration: const InputDecoration(
                        labelText: '아이디',
                        hintText: "아이디를 입력하세요",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: '비밀번호',
                        hintText: "비밀번호를 입력하세요",
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text('로그인 유지'),
                        ),
                        Switch(
                          trackOutlineColor:
                              MaterialStateProperty.all(Colors.grey),
                          inactiveThumbColor: Colors.grey[500],
                          inactiveTrackColor: Colors.grey[100],
                          activeTrackColor: Colors.blue[200],
                          activeColor: Colors.blue[900],
                          value: _keepLoggedIn,
                          onChanged: (value) {
                            // Update the state of _keepLoggedIn
                            setState(
                              () {
                                _keepLoggedIn = value;
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 250.0,
                      child: ElevatedButton(
                        onPressed: () => login(context),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            '로그인',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegistrationScreen()),
                        );
                      },
                      child: const Text(
                        '회원가입하기',
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
