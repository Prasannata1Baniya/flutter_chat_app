import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth-cubit/auth_cubit.dart';
import '../cubits/auth-cubit/auth_state.dart';
import '../widgets/my_text_field.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});


  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  bool isPasswordObscured = true;

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
      backgroundColor: const Color(0xFFF3F4F6),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthenticatedState) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
            );
          } else if (state is FailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: Colors.redAccent, content: Text(state.error)));
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- Header ---
                      const Icon(Icons.person_add_rounded, size: 70, color: Colors.blue),
                      const SizedBox(height: 16),
                      const Text("Create Account",
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const Text("Join our community today",
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 32),

                      // --- Input Fields ---
                      MyTextField(
                        hText: "Full Name",
                        controller: nameController,
                        obscureText: false,
                        validator: (value) {
                          if(value ==null || value.isEmpty){
                            return 'please enter your full name';
                          }
                          return null;
                        }, icon: const Icon(Icons.person),
                      ),
                      const SizedBox(height: 16),
                      
                      //Email
                      MyTextField(
                        hText: "Email Address",
                        controller: emailController,
                        obscureText: false,
                        validator: (value){
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        }, icon:const Icon(Icons.email_outlined),
                      ),
                      const SizedBox(height: 16),
                      
                      //Password
                      MyTextField(
                        hText: "Password",
                        controller: passwordController,
                        obscureText: true,
                        validator: (value) =>   (value == null || value.length < 6)
                            ? 'Short password'
                            : null, 
                        icon: IconButton(onPressed: (){
                          setState(() {
                            isPasswordObscured = !isPasswordObscured;
                          });
                        }, icon: isPasswordObscured ? const Icon(Icons.visibility_off_rounded)
                            :const Icon(Icons.visibility)
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- Register Button ---
                      GestureDetector(
                        /*onTap: () {
                          if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                            context.read<AuthCubit>().register(
                                nameController.text.trim(),
                                emailController.text.trim(),
                                passwordController.text.trim()
                            );}},*/
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().register(
                                nameController.text.trim(),
                                emailController.text.trim(),
                                passwordController.text.trim(),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(colors: [Colors.blue, Color(0xFF1E88E5)]),
                              boxShadow: [
                                BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))
                              ]
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          width: double.infinity,
                          child: BlocBuilder<AuthCubit,AuthState>(
                            builder: (context, state){
                              if (state is LoadingState) {
                                return const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white,
                                     strokeWidth: 2,
                                  ),
                                );
                              }
                            return const Text(
                              "Sign Up",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              textAlign: TextAlign.center,
                            );
                          }
                          ),
                        ),
                      ),

                      // --- Footer ---
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already a member?", style: TextStyle(color: Colors.black54)),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: Text(
                              " Login",
                              style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
