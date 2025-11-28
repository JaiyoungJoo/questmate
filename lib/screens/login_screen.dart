import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final AuthService auth;

  const LoginScreen({Key? key, required this.auth}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QuestMate 로그인')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: loading
              ? null
              : () async {
                  setState(() => loading = true);
                  try {
                    await widget.auth.signInWithGoogle();
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('로그인 실패: ${e.toString()}'),
                        ),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => loading = false);
                  }
                },
          icon: const Icon(Icons.login),
          label: Text(loading ? "로그인 중..." : "Google로 로그인"),
        ),
      ),
    );
  }
}
