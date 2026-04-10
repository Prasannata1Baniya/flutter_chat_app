import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_app/features/auth/presentation/pages/search_bar.dart';
import 'package:intl/intl.dart';
import '../cubits/auth-cubit/auth_cubit.dart';
import '../cubits/auth-cubit/auth_state.dart';


class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatUserName;
  final String chatUserUid;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.chatUserName,
    required this.chatUserUid,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _currentUserId;

  // Inside your _ChatScreenState class
  late final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentUserId = context.read<AuthCubit>().currentUser?.uid ?? '';
    debugPrint("!!!!!!!!!!!!!");
    debugPrint("MY UID: $_currentUserId");
    debugPrint("CHAT ROOM ID: ${widget.chatId}");
    debugPrint("!!!!!!!!!!!!!!");
    _searchController.addListener(() {
      setState(() {});
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    debugPrint("Sending message as: $_currentUserId");

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'senderId': _currentUserId,
      'receiverId': widget.chatUserUid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.blueGrey.shade50,
      backgroundColor:  const Color(0xFFF0F2F5),
      //backgroundColor: Colors.blue.shade50,
      /*appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue.shade100,
              child: Text(widget.chatUserName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Text(widget.chatUserName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),*/
      body: Row(
        children: [
          Container(
            width: 350,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
              color: Colors.grey.shade50,
            ),
            child: _buildSidebarList(),
          ),
          Container(width: 1, color: Colors.grey.shade200),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  constraints: const BoxConstraints(maxWidth: 800),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    /*boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      )
                    ],*/
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                    child:Column(
                      children: [
                        _buildCustomHeader(),
                        const Divider(height: 1,),
                        Expanded(
                          child: Container(
                           // color: Colors.grey.shade50,
                            // Inside your Chat Area Container
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue.shade50,
                                  Colors.blue.shade50,
                                ],
                              ),
                            ),
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('chats')
                                  .doc(widget.chatId)
                                  .collection('messages')
                                  .orderBy('timestamp', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                  return const Center(child: Text("No messages yet. Say hi!"));
                                }

                                final docs = snapshot.data!.docs;

                                return ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(20),
                                  reverse: true,
                                  itemCount: docs.length,
                                  itemBuilder: (context, index) {
                                    final data = docs[index].data() as Map<String, dynamic>;
                                    final isMe = data['senderId'] == _currentUserId;

                                    return _buildMessageBubble(
                                        data['text'] ?? '',
                                        isMe,
                                        data['timestamp'] as Timestamp?
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        _buildInputArea(),
                      ],
                    ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMessageBubble(String text, bool isMe, Timestamp? timestamp) {
    String time = '';
    if (timestamp != null) {
      time = DateFormat('hh:mm a').format(timestamp.toDate());
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isMe ? Colors.blue.shade600 : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      // WHITE text on Blue, BLACK text on White
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.grey.shade500,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.add_circle, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: "Aa",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send_rounded, color: Colors.blue, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue.shade50,
            child: Text(widget.chatUserName[0].toUpperCase(),
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Text(widget.chatUserName,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSidebarList() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // to get the list of users.
        // If the state isn't UsersFetched, we try to trigger the fetch.
        if (state is AuthenticatedState || state is AuthInitialState) {
          context.read<AuthCubit>().fetchUsersExcluding();
        }

        List<dynamic> users = [];
        if (state is UsersFetchedState) {
          users = state.users.where((user) {
            final name = user.name?.toLowerCase() ?? '';
            final query = _searchController.text.toLowerCase();
            return name.contains(query);
          }).toList();
        }

        return Container(
          width: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            children: [
              // Sidebar Title
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Chats",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
              ),

              CustomSearchBar(searchController: _searchController),

              // User List
              Expanded(
                child: state is LoadingState && users.isEmpty
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    : ListView.builder(
                  itemCount: users.length,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final bool isSelected = widget.chatUserUid == user.uid;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade50 : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        onTap: () {
                          if (!isSelected) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  chatId: _generateChatId(_currentUserId, user.uid),
                                  chatUserName: user.name ?? 'No Name',
                                  chatUserUid: user.uid,
                                ),
                              ),
                            );
                          }
                        },
                        leading: CircleAvatar(
                          backgroundColor: isSelected ? Colors.blue : Colors.blue.shade100,
                          child: Text(
                            user.name?[0].toUpperCase() ?? '?',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          user.name ?? 'No Name',
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? Colors.blue.shade700 : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          "Online",
                          style: TextStyle(color: Colors.green.shade600, fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Helper for navigation
  String _generateChatId(String id1, String id2) {
    List<String> ids = [id1, id2];
    ids.sort();
    return ids.join('_');
  }

/* Widget _buildInputArea() {

   return Container(

     padding: const EdgeInsets.all(15),

     decoration:const BoxDecoration(

       color: Colors.white,

       // boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))]

     ),

     child: SafeArea(

       child: Row(

         children: [

           Expanded(

             child: Container(

               padding: const EdgeInsets.symmetric(horizontal: 16),

               decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(25)),

               child: TextField(

                 controller: _messageController,

                 decoration: const InputDecoration(hintText: "Type a message...", border: InputBorder.none),

                 onSubmitted: (_) => _sendMessage(),

               ),

             ),

           ),

           const SizedBox(width: 10),

           IconButton(

             onPressed: _sendMessage,

             icon: const CircleAvatar(

               backgroundColor: Colors.blue,

               child: Icon(Icons.send_rounded, color: Colors.white, size: 20),

             ),

           ),

         ],

       ),

     ),

   );

 }*/

}

