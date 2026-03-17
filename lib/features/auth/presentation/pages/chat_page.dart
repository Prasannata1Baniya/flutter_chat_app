import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/chat_models.dart';
import '../cubits/auth-cubit/auth_cubit.dart';
import '../cubits/chat-cubit/chat_cubit.dart';
import '../cubits/chat-cubit/chat_state.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatUserName;
  final String chatUserUid;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.chatUserName,
    required this.chatUserUid
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _senderId = '';

  @override
  void initState() {
    super.initState();
    _senderId = context.read<AuthCubit>().currentUser?.uid ?? '';
    context.read<ChatCubit>().fetchMessage(widget.chatId);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leadingWidth: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Hero(
              tag: widget.chatUserUid,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  widget.chatUserName[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    widget.chatUserName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
                const Text(
                    "Online",
                    style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500)
                ),
              ],
            ),
          ],
        ),
      ),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
          }
        },
        builder: (context, state) {
          if (state is ChatLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      final isMe = msg.senderId == _senderId;
                      // FIX: Pass the entire 'msg' object, not just msg.text
                      return _buildMessageBubble(msg, isMe);
                    },
                  ),
                ),
                _buildInputArea(),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // FIX: Updated to accept the 'Message' object correctly
  Widget _buildMessageBubble(Message msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75
            ),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 20),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 5,
                    offset: const Offset(0, 2)
                )
              ],
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 16
              ),
            ),
          ),
          // Tiny timestamp under the bubble
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(
              msg.formattedTime, // Uses the helper from your Message model
              style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4)
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25)
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _sendMessage,
              child: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatCubit>().sendMessage(text, widget.chatId, _senderId);
    _messageController.clear();
  }
}