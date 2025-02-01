import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entity/user_entity.dart';
import '../cubits/auth-cubit/auth_cubit.dart';
import '../cubits/auth-cubit/auth_state.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

 /* @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().fetchUsersExcluding();
    });
  }
  */

  @override
  Widget build(BuildContext context) {
    //context.read<AuthCubit>().fetchUsersExcluding();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthCubit>().logOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthenticatedState) {
            // Fetch users after successful login
            context.read<AuthCubit>().fetchUsersExcluding();
          }
          if (state is FailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is LoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UsersFetchedState) {
            final List<UserEntity> users = state.users;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user.name ?? 'No Name'),
                  subtitle: Text(user.email),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(chatId: user.uid),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is NoUsersFoundState) { // Handle no users
            return const Center(child: Text("No other users found."));
          } else if (state is NoCurrentUserState) { // Handle no current user
            return const Center(child: Text("No current user found."));
          }else {
            return const Center(child: Text("Loading users..."));
          }
        },
      ),
    );
  }
}

