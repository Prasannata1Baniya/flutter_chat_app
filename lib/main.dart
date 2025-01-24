import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_app/features/auth/data/repo/auth_repo_impl.dart';
import 'package:flutter_chat_app/features/auth/data/repo/chat_repo_impl.dart';
import 'package:flutter_chat_app/features/auth/presentation/pages/home_page.dart';
import 'package:flutter_chat_app/firebase_options.dart';
import 'features/auth/presentation/cubits/auth-cubit/auth_cubit.dart';
import 'features/auth/presentation/cubits/auth-cubit/auth_state.dart';
import 'features/auth/presentation/cubits/chat-cubit/chat_cubit.dart';
import 'features/auth/presentation/pages/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Create instances of your repositories
  final authRepo = AuthRepoImpl(FirebaseFirestore.instance ,FirebaseAuth.instance,);
  final chatRepo = ChatRepoImpl(FirebaseFirestore.instance);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(authRepo: authRepo)..checkCurrentUser()),
        BlocProvider(create: (_) => ChatCubit(chatRepo)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
           if (state is FailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
         /*if (state is AuthInitialState) {
            return const Scaffold(
             body: Center(child: Text("Initializing...")),
           );
          }*/
          if (state is AuthenticatedState) {
          return const HomePage();
         }
          else if (state is UnAuthenticatedState) {
            return const AuthPage();
          }
          else if (state is LoadingState) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return const Placeholder(); // Placeholder for intermediate states
          }
        },
      ),
    );
  }
}
