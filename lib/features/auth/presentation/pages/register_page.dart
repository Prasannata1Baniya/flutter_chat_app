import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth-cubit/auth_cubit.dart';
import '../cubits/auth-cubit/auth_state.dart';
import '../widgets/my_text_field.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const  RegisterPage({super.key,required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;


  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Register Page")),
      ),
      body:BlocListener<AuthCubit,AuthState>(
          listener: (context,state){
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
          const Icon(Icons.app_registration,size: 100,),
          const SizedBox(height:30),
          MyTextField(hText: "name", controller: nameController)  ,
          const SizedBox(height:12),
          MyTextField(hText: "email", controller: emailController)  ,
          const SizedBox(height:12),
          MyTextField(hText: "password", controller: passwordController),
          const SizedBox(height:18),
          GestureDetector(
            onTap:() {
              context.read<AuthCubit>().register(
                  nameController.text.trim(),
                  emailController.text.trim(), passwordController.text.trim()
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color:Colors.black,
              ),
              child: const Text("Register",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,
                  color: Colors.white),
              ),
            ),
          ),
          Row(
            children: [
              const Text("Already a member!"),
              GestureDetector(
                onTap: widget.onTap,
                child:const Text("Login!",style: TextStyle(color:Colors.blue),),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
