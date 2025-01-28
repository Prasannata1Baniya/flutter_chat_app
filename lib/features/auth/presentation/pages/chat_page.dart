
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/chat-cubit/chat_cubit.dart';
import '../cubits/chat-cubit/chat_state.dart';

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

