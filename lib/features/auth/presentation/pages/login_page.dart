import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_app/features/auth/presentation/widgets/my_text_field.dart';

class LoginPage extends StatelessWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController=TextEditingController();
    final TextEditingController passwordController=TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Login Page")),
      ),
        body:Column(
          children: [
           const Icon(Icons.login,size: 100,),
           const SizedBox(height:30),
           MyTextField(hText: "email", controller: emailController)  ,
           const SizedBox(height:12),
            MyTextField(hText: "password", controller: passwordController),
            const SizedBox(height:18),
            GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color:Colors.black,
                ),
                child: const Text("Login",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,
                color: Colors.white),
                ),
              ),
            ),
            const Text("New member!"),
            GestureDetector(
                onTap: onTap,
                child:const Text("Register now"),
            ),
          ],
        ),
    );
  }
}
