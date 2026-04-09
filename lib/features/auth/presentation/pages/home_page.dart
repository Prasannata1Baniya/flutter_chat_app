
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_app/features/auth/presentation/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cubits/auth-cubit/auth_cubit.dart';
import '../cubits/auth-cubit/auth_state.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allUsers = [];
  List<dynamic> _filteredUsers = [];

  String generateChatId(String id1, String id2) {
    List<String> ids = [id1, id2];
    ids.sort();
    return ids.join('_');
  }

  Uint8List? _profileImageBytes;



  Future<void> _loadCurrentUserData() async {
    final user = context.read<AuthCubit>().currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    // Using the unique key: profile_image_UID
    final String? base64String = prefs.getString('profile_image_${user.uid}');

    if (base64String != null) {
      setState(() {
        // Make sure you are updating the same variable used in your build method
        _profileImageBytes = base64Decode(base64String);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().fetchUsersExcluding();
      // Load image after the frame is built to ensure Cubit is accessible
      _loadCurrentUserData();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final name = (user.name ?? "").toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {

    final currentUser = context.watch<AuthCubit>().currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is UsersFetchedState) {
            _allUsers = state.users;
            if (_searchController.text.isEmpty) {
              _filteredUsers = state.users;
            }
          }

          if (_allUsers.isNotEmpty) {
           // final currentUserId = currentUser?.uid ?? '';
            return Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: GestureDetector(
                        //onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfilePage())
                          );
                          // Refresh the local bytes after returning from profile edit
                          _loadCurrentUserData();
                        },
                        child: Hero(
                          tag: 'profile_pic',
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue.shade50, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.blue.shade50,
                              // ADD THIS LINE:
                              backgroundImage: _profileImageBytes != null
                                  ? MemoryImage(_profileImageBytes!)
                                  : null,
                              child: _profileImageBytes == null
                                  ? Text(
                                currentUser?.name?[0].toUpperCase() ?? 'U',
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20
                                ),
                              )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Chats",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: -0.5),
                    ),
                    const Spacer(),
                       Padding(
                        //padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        child: Card(
                          elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          ),
                          child: SizedBox(
                            width: 500,
                            height: 42,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                focusedBorder:  OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: const BorderSide(
                                      width: 1, color: Colors.lightBlue),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                                 ),
                                hintText: "Search friends...",
                                hintStyle: TextStyle(color: Colors.grey.shade500,
                                    fontSize: 15),
                                prefixIcon: Icon(Icons.search_rounded, color: Colors
                                    .grey.shade600, size: 22),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () => _searchController.clear(),
                                )
                                    : null,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const Spacer(),

                    //Log out
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: (){
                          showDialog(context: context, builder: (context){
                            return AlertDialog(
                              title:const Text('Log out'),
                              content:  const Text('Are you sure you want to log out'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await context.read<AuthCubit>().logOut();
                                  },
                                  child: const Text("Logout", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          });
                        },
                        // onPressed: () => context.read<AuthCubit>().logOut(),
                        icon: const Icon(Icons.logout_rounded, color: Colors.black, size: 22),
                      ),
                    ),
                  ],
                ),

                //Chat List
                /*Expanded(
                  child: _filteredUsers.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                    padding: const EdgeInsets.only(top: 10, bottom: 100),
                    itemCount: _filteredUsers.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 90, endIndent: 20,
                        color: Color(0xFFF5F5F5),thickness: 1,),
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      final chatId = generateChatId(currentUserId, user.uid);

                      return ListTile(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              chatId: chatId,
                              chatUserName: user.name ?? 'No Name',
                              chatUserUid: user.uid,
                            ),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Hero(
                          tag: user.uid,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue.shade50,
                            child: Text(user.name?[0].toUpperCase() ?? '?',
                                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20)),
                          ),
                        ),
                        title: Text(
                          user.name ?? 'No Name',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "Tap to start chatting...",
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("12:45 PM", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                            const SizedBox(height: 5),
                          ],
                        ),
                      );
                    },
                  ),
                ),*/

                const Divider(height: 1),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 650),
                      child: _filteredUsers.isEmpty
                          ? _buildEmptyState()
                          : ListView
                          .builder(
                        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          final currentUserId = currentUser?.uid ?? '';
                          final chatId = generateChatId(currentUserId, user.uid);
                          return Card(
                            elevation: 5,
                            color: Colors.white,
                            child: ListTile(
                              onTap: () =>
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ChatScreen(
                                            chatId: chatId,
                                            chatUserName: user.name ?? 'No Name',
                                            chatUserUid: user.uid,
                                          ),
                                    ),
                                  ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 8),
                              leading: Stack(
                                children: [
                                  Hero(
                                    tag: user.uid,
                                    child: CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.blue.shade50,
                                      child: Text(
                                        user.name?[0].toUpperCase() ?? '?',
                                        style: const TextStyle(color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              title: Text(
                                user.name ?? 'No Name',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text(
                                "Tap to chat",
                                style: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 13),
                              ),
                              trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded, size: 14,
                                  color: Colors.black),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
            return _buildLoadingOrError(state);
          }
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.blue,
        label: const Text("New Chat", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 10),
          Text("No users found", style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildLoadingOrError(AuthState state) {
    if (state is FailureState) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text("Error: ${state.error}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    return const Center(child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 2));
  }
}