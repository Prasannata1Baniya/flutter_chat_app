import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_app/features/auth/presentation/pages/profile_page.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().fetchUsersExcluding();
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        toolbarHeight: 90,
        centerTitle: false,
        leadingWidth: 75,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
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
                  child: Text(
                    currentUser?.name?[0].toUpperCase() ?? 'U',
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          "Chats",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -1),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthCubit>().logOut(),
            icon:const Icon(Icons.logout_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is UsersFetchedState) {
            _allUsers = state.users;
            if (_searchController.text.isEmpty) {
              _filteredUsers = state.users;
            }
          }

          if (_allUsers.isNotEmpty) {
            final currentUserId = currentUser?.uid ?? '';

            return Column(
              children: [

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        focusedBorder:const OutlineInputBorder(
                          borderSide: BorderSide(width: 1,color: Colors.lightBlue),
                        ),
                        hintText: "Search conversations...",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: const Icon(Icons.search, color: Colors.black, size: 22),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),

                //Chat List
                Expanded(
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
                ),
              ],
            );
          }

          return _buildLoadingOrError(state);
        },
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