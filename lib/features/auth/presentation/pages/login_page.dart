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
      backgroundColor: const Color(0xFFF3F4F6),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthenticatedState) {
            Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => const HomePage()));
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
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
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
                  mainAxisSize: MainAxisSize.min, // Wrap content
                  children: [
                    // --- Header ---
                    const Icon(Icons.chat_bubble_rounded, size: 70, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text("Welcome Back",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const Text("Sign in to continue",
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 32),

                    // --- Input Fields ---
                    MyTextField(
                      hText: "Email",
                      controller: emailController,
                      obscureText: false,
                    ),
                    const SizedBox(height: 16),
                    MyTextField(
                      hText: "Password",
                      controller: passwordController,
                      obscureText: true, // Should be true for passwords
                    ),
                    const SizedBox(height: 10),

                    // --- Forgot Password (Optional UI Polish) ---
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text("Forgot Password?",
                          style: TextStyle(color: Colors.blue.shade700, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    GestureDetector(
                      onTap: () {
                        context.read<AuthCubit>().login(
                            emailController.text.trim(),
                            passwordController.text.trim());
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
                          "Login",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    // Footer
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Not a member?", style: TextStyle(color: Colors.black54)),
                        GestureDetector(
                          onTap: onTap,
                          child: Text(
                            " Register now",
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
