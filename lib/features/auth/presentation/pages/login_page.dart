import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth-cubit/auth_cubit.dart';
import '../cubits/auth-cubit/auth_state.dart';
import '../widgets/my_text_field.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Login Page")),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthenticatedState) {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => const HomePage()));
          } else if (state is FailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.login, size: 100),
              const SizedBox(height: 30),
              MyTextField(hText: "Email", controller: emailController,
                obscureText:false ,),
              const SizedBox(height: 12),
              MyTextField(hText: "Password", controller: passwordController,
                obscureText: false,),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () {
                  context.read<AuthCubit>().login(
                      emailController.text.trim(),
                      passwordController.text.trim());
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  width: double.infinity,
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("New member?"),
                  GestureDetector(
                    onTap: onTap,
                    child: const Text(
                      " Register now",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}









/*class LoginPage extends StatelessWidget {
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
        body:BlocListener<AuthCubit,AuthState>(listener: (context,state){
          if(state is AuthenticatedState){
            Navigator.push(context, MaterialPageRoute(
                builder: (context)=> const HomePage()));
          }else if(state is FailureState){
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)));
          }
        },
        child: Column(
          children: [
          const Icon(Icons.login,size: 100,),
      const SizedBox(height:30),
      MyTextField(hText: "email", controller: emailController)  ,
      const SizedBox(height:12),
      MyTextField(hText: "password", controller: passwordController),
      const SizedBox(height:18),
      GestureDetector(
        onTap: (){
          context.read<AuthCubit>().login(emailController.text.trim(),
              passwordController.text.trim());
        },
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
      Row(
        children: [
          const Text("New member!"),
          GestureDetector(
            onTap: onTap,
            child:const Text("Register now",style: TextStyle(color: Colors.blue),),
          ),
        ],
      ),
      ],
    ),
        )
    );
  }
}
*/