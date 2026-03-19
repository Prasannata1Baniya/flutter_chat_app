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
  // 1. Controller for the Search Bar
  final TextEditingController _searchController = TextEditingController();

  // 2. Lists to hold all users and the filtered results
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

    // 3. Listen to search text changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 4. Filtering Logic
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
    final currentUser = context.read<AuthCubit>().currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 80,
        centerTitle: false,
        leadingWidth: 75,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.blue.shade50,
              child: Text(
                currentUser?.name?[0].toUpperCase() ?? 'U',
                style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          ),
        ),
        title: const Text(
          "Chats",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w800, fontSize: 28),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              onPressed: () => context.read<AuthCubit>().logOut(),
              icon: Icon(Icons.logout_rounded, color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is UsersFetchedState) {
            // 5. Update local lists when new data arrives from Cubit
            if (_allUsers.isEmpty || _allUsers.length != state.users.length) {
              _allUsers = state.users;
              if (_searchController.text.isEmpty) {
                _filteredUsers = state.users;
              }
            }


            final currentUserId = context.read<AuthCubit>().currentUser?.uid ?? '';

            return Column(
              children: [
                // -- Search Bar --
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextField(
                    controller: _searchController, // Attached controller
                    decoration: InputDecoration(
                      hintText: "Search messages...",
                      prefixIcon: const Icon(Icons.search, size: 20),
                      // Added a clear button when user types
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // --- Chat List ---
                Expanded(
                  child: _filteredUsers.isEmpty
                      ? const Center(child: Text("No users found"))
                      : ListView.builder(
                    itemCount: _filteredUsers.length, // Use filtered list
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      final chatId = generateChatId(currentUserId, user.uid);
                      return InkWell(
                        onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: chatId, // Now both users will have the SAME ID
                            chatUserName: user.name ?? 'No Name',
                            chatUserUid: user.uid,
                          ),
                        ),
                      ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          child: Row(
                            children: [
                              Hero(
                                tag: user.uid,
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.blue.shade50,
                                  child: Text(user.name?[0].toUpperCase() ?? '?',
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22)),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user.name ?? 'No Name',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17)),
                                    const SizedBox(height: 5),
                                    Text("Tap to start chatting...",
                                        style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("12:45 PM",
                                      style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 12)),
                                  const SizedBox(height: 5),
                                ],
                              ),
                            ],
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        child: const Icon(Icons.edit_square, color: Colors.white),
      ),
    );
  }

  Widget _buildLoadingOrError(AuthState state) {
    if (state is FailureState) {
      return Center(child: Text("Error: ${state.error}"));
    }
    return const Center(child: CircularProgressIndicator(color: Colors.blue));
  }
}
