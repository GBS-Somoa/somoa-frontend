import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:somoa/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:somoa/screens/main_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nicknameController = TextEditingController();

  Future<void> _saveKeepLoggedIn(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepLoggedIn', value);
  }

  bool isKeepLoggedIn = false;

  bool _isFormValid = false;
  bool _isIdFormValid = false;
  bool _isPasswordValid = false;
  bool _isPassword1Valid = false;
  bool _isPasswordMatch = false;
  bool _isNicknameFormValid = false;

  @override
  void initState() {
    super.initState();

    idController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
    nicknameController.addListener(_validateForm);
  }

  bool _validatePassword(String password) {
    RegExp regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,20}$');
    return regex.hasMatch(password);
  }

  void _validateForm() {
    bool isPasswordCompliant = _validatePassword(passwordController.text);
    bool isPasswordsMatch =
        passwordController.text == confirmPasswordController.text;
    setState(() {
      _isFormValid = idController.text.isNotEmpty &&
          isPasswordCompliant &&
          isPasswordsMatch &&
          nicknameController.text.isNotEmpty;
      _isPassword1Valid = isPasswordCompliant;
      _isPasswordMatch = isPasswordsMatch;
      _isPasswordValid = isPasswordCompliant && isPasswordsMatch;
      _isIdFormValid = idController.text.isNotEmpty;
      _isNicknameFormValid = nicknameController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    idController.dispose();
    nicknameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp(BuildContext context) async {
    // signUp 로직 작성
    final signUpResult = await Provider.of<UserProvider>(context, listen: false)
        .signUp(
            username: idController.text,
            password: passwordController.text,
            nickname: nicknameController.text);
    if (signUpResult == "success") {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text('${nicknameController.text}님 환영합니다.'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('성공적으로 회원가입되었습니다.'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: isKeepLoggedIn,
                            onChanged: (value) {
                              setState(() {
                                isKeepLoggedIn = value!;
                              });
                            },
                          ),
                          const Text('로그인 유지'),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        await _saveKeepLoggedIn(isKeepLoggedIn);
                        final loginResult = await Provider.of<UserProvider>(
                                context,
                                listen: false)
                            .login(
                                keepLoggedIn: isKeepLoggedIn,
                                username: idController.text,
                                password: passwordController.text);
                        if (loginResult == "success") {
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MainScreen()),
                                (route) => false);
                          }
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('로그인 실패'),
                              content: Text(loginResult!),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('확인'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: const Text("확인"),
                    )
                  ],
                );
              },
            );
          },
        );
      }
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('회원가입 실패'),
            content: Text(signUpResult!),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          children: [
            Icon(Icons.how_to_reg),
            Text(
              '회원가입',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Form(
                    child: Column(children: [
                  TextFormField(
                    controller: idController,
                    decoration: InputDecoration(
                      labelText: '아이디',
                      hintText: "아이디를 입력하세요",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: _isIdFormValid
                                ? const Color.fromARGB(255, 49, 195, 97)
                                : Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      hintText: "비밀번호를 입력하세요",
                      errorText: !_isPassword1Valid &&
                              passwordController.text.isNotEmpty
                          ? "영어와 숫자를 포함하여 8 - 20자로 입력하세요"
                          : null,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: _isPasswordValid
                                ? const Color.fromARGB(255, 49, 195, 97)
                                : Colors.grey),
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: '비밀번호 확인',
                      hintText: "비밀번호를 재입력하세요",
                      helperText: _isPasswordValid ? "비밀번호가 일치합니다" : null,
                      helperStyle: const TextStyle(
                          color: Color.fromARGB(255, 49, 195, 97)),
                      errorText: confirmPasswordController.text.isNotEmpty &&
                              !_isPasswordMatch
                          ? "비밀번호가 일치하지 않습니다"
                          : null,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: _isPasswordValid
                                ? const Color.fromARGB(255, 49, 195, 97)
                                : Colors.grey),
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: nicknameController,
                    decoration: InputDecoration(
                      labelText: '닉네임',
                      hintText: '닉네임을 입력하세요',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: _isNicknameFormValid
                                ? const Color.fromARGB(255, 49, 195, 97)
                                : Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: _isFormValid ? () => signUp(context) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFormValid
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          '회원가입',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ]))),
          ),
        ),
      ),
    );
  }
}
