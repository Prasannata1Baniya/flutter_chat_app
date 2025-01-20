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

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final authRepo=AuthRepoImpl(FirebaseAuth.instance as FirebaseFirestore);
  final chatRepo=ChatRepoImpl(FirebaseAuth.instance as FirebaseFirestore);

  runApp(
    MultiBlocProvider(providers: [
      BlocProvider(create: (_)=> AuthCubit(authRepo: authRepo)),
      BlocProvider(create: (_)=> ChatCubit(chatRepo)),
    ], child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  final authRepo=AuthRepoImpl(FirebaseFirestore.instance);
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: ( context)=> AuthCubit(authRepo: authRepo)..checkCurrentUser(),
      child: MaterialApp(
        home:BlocConsumer<AuthCubit,AuthState>(
            builder: (context,state) {
              if(state is AuthenticatedState){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context)=>const HomePage()));
              }
              if(state is UnAuthenticatedState){
                return const AuthPage();
              }
              else{
                return const Scaffold(
                    body:CircularProgressIndicator()
                );
              }
            },
            listener: (context,state){
              if(state is FailureState){
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error)));
              }
            }
        ),
      ),
    );
  }
}
