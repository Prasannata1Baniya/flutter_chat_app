import 'package:flutter/material.dart';
import 'package:flutter_chat_app/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_chat_app/features/auth/presentation/pages/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin=true;

  void togglePage(){
    setState(() {
      isLogin =!isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
   return  AnimatedSwitcher(
      duration: const Duration(milliseconds: 300), // Optional animation duration
      child: isLogin
          ? LoginPage(onTap: togglePage)
          : RegisterPage(onTap: togglePage),
    );
  }
}
