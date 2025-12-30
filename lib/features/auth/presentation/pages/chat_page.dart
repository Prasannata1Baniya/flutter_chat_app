import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth-cubit/auth_cubit.dart';
import '../cubits/chat-cubit/chat_cubit.dart';
import '../cubits/chat-cubit/chat_state.dart';


class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatUserName;
  const ChatScreen({super.key, required this.chatId, required this.chatUserName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _senderId = '';
  bool _canSend = false;

  @override
  void initState() {
    super.initState();

    // Get current user ID from AuthCubit
    final authCubit = context.read<AuthCubit>();
    _senderId = authCubit.currentUser?.uid ?? '';

    // Fetch messages for the chat
    context.read<ChatCubit>().fetchMessage(widget.chatId);

    // Listen for text changes to enable/disable send button
    _messageController.addListener(() {
      setState(() {
        _canSend = _messageController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.chatUserName,style:const TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),


      ),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatLoaded) {
            // Scroll to bottom when new messages arrive
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });
          } else if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.error}')),
            );
          }
        },
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatLoaded) {
            final messages = state.messages;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == _senderId;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blueAccent : Colors.grey.shade300,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 0),
                              bottomRight: Radius.circular(isMe ? 0 : 16),
                            ),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type your message...',
                              border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _trySendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.send, color: _canSend ? Colors.blue : Colors.grey),
                          onPressed: _canSend ? _trySendMessage : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (state is ChatError) {
            return Center(child: Text('Error: ${state.error}'));
          } else {
            return const Center(child: Text('No messages'));
          }
        },
      ),
    );
  }

  void _trySendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatCubit>().sendMessage(text, widget.chatId, _senderId);
    _messageController.clear();
  }
}


/*class ChatScreen extends StatefulWidget {
  final String chatId;
  const ChatScreen({super.key,required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch messages for the chatId when the screen is initialized
    context.read<ChatCubit>().fetchMessage(widget.chatId);
  }

  @override
  void dispose() {
    messageController.dispose(); // Dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Screen'),
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return ListTile(
                        title: Text(message.text),
                        // Optionally, you can add more details like sender name or timestamp
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: const InputDecoration(
                            labelText: 'Message',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (messageController.text.isNotEmpty) {
                            // Replace 'your_sender_id' with the actual sender ID
                            context.read<ChatCubit>().sendMessage(
                              widget.chatId,
                              messageController.text,
                              'your_sender_id', // Replace with actual sender ID
                            );
                            messageController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (state is ChatError) {
            return Center(child: Text('Error: ${state.error}'));
          } else {
            return const Center(child: Text('No messages'));
          }
        },
      ),
    );
  }
}





class ChatScreen extends StatelessWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController messageController = TextEditingController();

    // Fetch messages for the chatId
    context.read<ChatCubit>().fetchMessage(chatId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Screen'),
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return ListTile(
                        title: Text(message.text),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: const InputDecoration(
                              labelText: 'Message'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (messageController.text.isNotEmpty) {
                            context.read<ChatCubit>().sendMessage(
                              chatId,
                              messageController.text,
                              'your_sender_id',
                            );
                            messageController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (state is ChatError) {
            return Center(child: Text('Error: ${state.error}'));
          } else {
            return const Center(child: Text('No messages'));
          }
        },
      ),
    );
  }
}

*/