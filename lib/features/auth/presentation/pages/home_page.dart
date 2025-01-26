import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_app/features/auth/presentation/cubits/auth-cubit/auth_cubit.dart';

import '../../domain/entity/user_entity.dart';
import '../cubits/auth-cubit/auth_state.dart';
import 'chat_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Home Page")),
        actions:[
           IconButton(
               onPressed: (){
                 context.read<AuthCubit>().logOut();
               },
               icon:const Icon(Icons.logout)
           ),
        ]
      ),
      body: BlocConsumer(builder: (context,state){
       if(state is LoadingState){
         return const CircularProgressIndicator();
       }
       else if(state is UsersFetchedState){
         final List<UserEntity> users=state.users;
         return ListView.builder(
           itemCount: users.length,
             itemBuilder:(context,index){
               final user=users[index];
           return GestureDetector(
             onTap: (){
               //context.read<ChatCubit>().
               Navigator.push(context, MaterialPageRoute(
                   builder: (context)=>ChatScreen(chatId: user.uid)));
             },
             child: ListTile(
               title: Text(user.name ?? ''),
               subtitle: Text(user.email),
             ),
           );
         });
       }
       else{
         return const Text("Users not found");
       }
      },
          listener: (context,state){
             if(state is FailureState){
               ScaffoldMessenger.of(context).showSnackBar
                 (
                   const SnackBar(content: Text("No users found!"),
                     backgroundColor: Colors.red,),
               );
             }
          }),
    );
  }
}
