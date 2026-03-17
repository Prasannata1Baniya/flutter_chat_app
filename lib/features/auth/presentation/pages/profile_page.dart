import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth-cubit/auth_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().currentUser;
    return Scaffold(
      body:Column(
        children: [
          CircleAvatar(
            radius: 50,
            child: Text(
              currentUser!.name?[0].toUpperCase() ?? 'U',
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Text(currentUser.name ?? '',
            style: const TextStyle(color: Colors.black,
                fontSize: 60, fontWeight: FontWeight.normal),
          ),
          const SizedBox(height: 10,),
          Text(currentUser.email,
            style: const TextStyle(color: Colors.black,
                fontSize: 60, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
