import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/features/auth/data/models/chat_models.dart';
import 'package:flutter_chat_app/features/auth/domain/repo/chat_repo.dart';

class ChatRepoImpl implements ChatRepo {
  final FirebaseFirestore _firestore;

  ChatRepoImpl(this._firestore);

  @override
  Stream<List<Message>> getMessages(String chatID) {
    return _firestore
        .collection('chats')
        .doc(chatID)
        .collection('messages')
    // Order by timestamp to ensure messages stay in the correct order for all users
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // FIX: Use 'fromMap' instead of 'fromDocument'
        // We pass the data and the document ID separately
        return Message.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<void> sendMessage(String chatId, Message message) async {
    try {
      // FIX: Use the toMap() method from your model.
      // It already contains 'FieldValue.serverTimestamp()' logic.
      final messageData = message.toMap();

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(messageData);

    } catch (e) {
      debugPrint("Error sending message: $e");
      throw Exception("Failed to send message. Please try again.");
    }
  }
}