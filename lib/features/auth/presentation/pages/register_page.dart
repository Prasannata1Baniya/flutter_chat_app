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
                    ),
                    const SizedBox(height: 16),
                    MyTextField(
                      hText: "Email Address",
                      controller: emailController,
                      obscureText: false,
                    ),
                    const SizedBox(height: 16),
                    MyTextField(
                      hText: "Password",
                      controller: passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 32),

                    // --- Register Button ---
                    GestureDetector(
                      onTap: () {
                        if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                          context.read<AuthCubit>().register(
                              nameController.text.trim(),
                              emailController.text.trim(),
                              passwordController.text.trim()
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please fill in all fields")));
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
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
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
    );
  }
}
