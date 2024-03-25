import 'package:flutter/material.dart';

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

  String confirmPasswordErrorText = '';

  bool isKeepLoggedIn = false; // Default value for keepLoggedIn checkbox

  @override
  void initState() {
    super.initState();
    // 비밀번호, 비밀번호 확인에 담긴 문자열이 일치하는지 확인 => 불일치하면 에러메시지 생성됨
    confirmPasswordController.addListener(() {
      setState(() {
        if (confirmPasswordController.text != passwordController.text) {
          confirmPasswordErrorText = "비밀번호가 일치하지 않습니다";
        } else {
          confirmPasswordErrorText = '';
        }
      });
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

  void signUp(BuildContext context) {
    // signUp 로직 작성
    Map<String, String> data = {
      "id": idController.text,
      "password": passwordController.text,
      "nickname": nicknameController.text
    };

    print(data);

    // TODO : 서버로 요청 전송, 회원가입 성공하면 로그인화면 띄움

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('${data["nickname"]}님 환영합니다.'),
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
                  onPressed: () {
                    if (isKeepLoggedIn) {
                      // TODO: keep login 로직 작성
                      print("로그인 유지");
                    }
                    Navigator.pushReplacementNamed(context, '/main');
                  },
                  child: const Text("확인"),
                )
              ],
            );
          },
        );
      },
    );

    // Navigator.pushReplacementNamed(context, '/login');
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
                      counterText: "영어, 숫자 8 - 20자", // 글자수, 형식 제한 (검증과정 없음)
                      border: OutlineInputBorder(),
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
                      errorText: confirmPasswordErrorText.isNotEmpty
                          ? confirmPasswordErrorText
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: nicknameController,
                    decoration: const InputDecoration(
                      labelText: '닉네임',
                      hintText: '닉네임을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () => signUp(context),
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
