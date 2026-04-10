
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_app/features/auth/presentation/pages/profile_page.dart';
import 'package:flutter_chat_app/features/auth/presentation/pages/search_bar.dart';
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
    //_searchController.addListener(() =>setState(() {}));
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
      backgroundColor: Colors.blue.shade50,
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
                              backgroundColor: Colors.blue,
                              // ADD THIS LINE:
                              backgroundImage: _profileImageBytes != null
                                  ? MemoryImage(_profileImageBytes!)
                                  : null,
                              child: _profileImageBytes == null
                                  ? Text(
                                currentUser?.name?[0].toUpperCase() ?? 'U',
                                style: const TextStyle(
                                    color: Colors.white,
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
                      style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: -0.5),
                    ),
                    const Spacer(),

                    //Searchbar
                    CustomSearchBar(searchController: _searchController),

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

                const Divider(height: 1),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 650),
                      child: _filteredUsers.isEmpty
                          ? _buildEmptyState()
                          : ListView
                          .builder(
                        padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 10),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          final currentUserId = currentUser?.uid ?? '';
                          final chatId = generateChatId(currentUserId, user.uid);
                          return Container(
                            margin:const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.grey.shade100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            /*elevation: 1,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(20),
                              side:const BorderSide(width: 0.5, color: Colors.black54),
                            ),*/
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
                                      backgroundColor: Colors.blue,
                                      child: Text(
                                        user.name?[0].toUpperCase() ?? '?',
                                        style: const TextStyle(color: Colors.white,
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
                                    fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              subtitle: Text(
                                "Tap to chat",
                                style: TextStyle(
                                    color: Colors.grey.shade500, fontSize: 15),
                              ),
                              trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded, size: 18,
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
