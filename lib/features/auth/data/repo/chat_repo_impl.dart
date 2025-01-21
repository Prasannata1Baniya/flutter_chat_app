import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/features/auth/data/models/chat_models.dart';
import 'package:flutter_chat_app/features/auth/domain/repo/chat_repo.dart';

class ChatRepoImpl implements ChatRepo {
  final FirebaseFirestore _firestore;

  ChatRepoImpl(this._firestore);

  @override
  Stream<List<Message>> getMessages(String chatID) {
    return _firestore.collection('chats/$chatID/messages').snapshots().map(
          (snapshot) {
        return snapshot.docs.map((doc) => Message.fromDocument(doc)).toList();
      },
    );
  }

  @override
  Future<void> sendMessage(String chatId, Message message) async {
    try {
      await _firestore.collection('chats/$chatId/messages').add(message.toMap());
    } catch (e) {
      debugPrint("Error sending message: $e");
      throw Exception("Failed to send message");
    }
  }
}